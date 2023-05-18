[toc]



# 一、WSGI简介

WSGI是类似于Servlet规范的一个通用的接口规范。和Servlet类似，只要编写的程序符合WSGI规范，就可以在支持WSGI规范的Web服务器中运行，就像符合Servlet规范的应用可以在Tomcat和Jetty中运行一样。

一个最小的Hello World的WSGI程序如下。

```python
from wsgiref import simple_server


def application(environ, start_response):
    start_response('200 OK', [('Content-Type', 'text/plain')])
    return [b'Hello World!']


http_server = simple_server.make_server('0.0.0.0', 5000, application)
http_server.serve_forever()

```

可以看到wsgi程序的定义只需要实现一个application即可。很简单的3行代码就实现了对http请求的处理。其中`enviorn`参数是一个`dict`，包含了系统的环境变量和HTTP请求的相关参数。

关于`start_response`，我们现在这里复习下Http协议的内容
Http Request需要包含以下部分

- 请求方法 — 统一资源标识符(Uniform Resource Identifier, URI) — 协议/版本
- 请求头(Header)
- 实体(Body)

具体示例为:

```
POST /examples/default HTTP/1.1
Accept: text/plain; text/hteml
Accept-Language: en-gb
Connection: Keep-Alive
Host: locahost
User-Agent: Mozilla/4.0 (compatible; MSIE 4.0.1; Windoes 98)
Content-Length: 33
Content-Type application/x-www-form-urlencoded
Accept-Encoding: gzip, deflate

lastName=Franks&firstName=Michael

```

其中body上面的空行为CRLF(\r\n), 对协议很重要，决定着request body从哪里开始解析。

Http Response需要包含以下部分

- 协议 — 状态码 — 描述
- 响应头(header)
- 响应实体(body)

具体示例为:

```
HTTP/1.1 200 OK
Server: Microsoft-IIS/4.0
Content-Type: text/plain
Content-Length: 12

Hello world!

```

那么现在再来看`start_response`函数, 第一个参数在写着`状态码`和`描述`。第二个参数是一个列表，写着response header。而`application`的返回值则代表着response body。

# 二、Werkzeug的Demo

了解了WSGI，我们再看下如何使用Werkzeug来写Hello World。

```python
from wsgiref import simple_server

from werkzeug.wrappers import Request, Response


def application(environ, start_response):
    request = Request(environ)
    query_string = request.query_string
    request_method = request.method
    request_data = request.data
    text = 'Hello %s!' % request.args.get('name', 'World')
    response = Response(text, mimetype='text/plain')
    return response(environ, start_response)


http_server = simple_server.make_server('0.0.0.0', 5000, application)
http_server.serve_forever()


```

在这里可以看到Werkzeug的作用，如果自己手写WSGI的程序的话，需要自己解析environ，以及自己处理返回值。而使用了Werkzeug就可以通过该库所提供的Request和Response来简化开发。正如官网的介绍Werkzeug is a utility library for WSGI；

在这篇文章中主要分析Werkzeug是如何实现相关的工具，进而简化WSGI程序的开发的。了解
Werkzeug也为后续理解Flask打下了坚实的基础。

# 三、Werkzeug提供的工具

(1) Request和Response对象，方便处理请求和响应
(2) Map、Rule以及MapAdapter，方便处理请求路由

(3) WSGI Helper, 比如一些编解码的处理，以及一些方便对stream的处理等。
(4) Context Locals提供了Local，类似于Java的ThreadLocal
(5) Http Exception用于处理相关的异常，比如404等。
(6) http.py中还提供了很多的http code和header的定义
除了这些工具还有很多，具体可以查看下官网。

在这篇文章中重点来解析Request和Response以及路由相关的源码。

# 四、wrappers分析

在Werkzeug并没有多少的包, wrappers是其中之一。

我们先从request = Request(environ)这行代码入手。分析Request。
注意，下面的复制粘贴的源码会删除掉与主流程不太相关的代码。方便理解核心流程。

## (1) class Request分析

首先，其实不用多说也知道Request无非是解析了`environ`dict而已。
Request继承了很多类，可以看到存在着Accept、ETAG、CORS等相关Header的解析

```python
class Request(
    BaseRequest,
    AcceptMixin,
    ETagRequestMixin,
    UserAgentMixin,
    AuthorizationMixin,
    CORSRequestMixin,
    CommonRequestDescriptorsMixin,
):
```

BaseRequest的构造方法为

```python

    def __init__(self, environ, populate_request=True, shallow=False):
        self.environ = environ
        if populate_request and not shallow:
            self.environ["werkzeug.request"] = self
        self.shallow = shallow
```

### 1. request.query_string和request.method

```python
class BaseRequest(object):
    ...
    # 描述符代理类，访问 request.query_string 相当于访问 environ_property.__get__
    query_string = environ_property(
            "QUERY_STRING",
            "",
            read_only=True,
            load_func=lambda x: x.encode("latin1"),
            doc="The URL parameters as raw bytes.",

class environ_property(_DictAccessorProperty): # 继承描述符类
    read_only = True

    def lookup(self, obj):
        return obj.environ
        
class _DictAccessorProperty(object): 	# 描述符类
    ...
    def __get__(self, obj, type=None):# obj: <Request 'http://192.168.6.128:5000/' [GET]>
        if obj is None:
            return self
        storage = self.lookup(obj)		# self: <environ_property QUERY_STRING>
        if self.name not in storage:
            return self.default
        rv = storage[self.name]
        if self.load_func is not None:
            try:
                rv = self.load_func(rv)
            except (ValueError, TypeError):
                rv = self.default
        return rv
```

可以看到先通过lookup方法获取了`environ` dict，也就是stroage变量，然后在获取了rv。也就是`environ`dict里面的key='QUERY_STRING’的value。
其实获取method(GET, POST)也是一样的实现

### 2. request.data

这个是获取Request Body， 在`environ` dict中，通过wsgi.input来获取的`BufferedReader`类来读取body中的数据。

```python
class BaseRequest(object):
    # data = cached_property(data), request.data 访问 cached_property.__get__()方法
	@cached_property	 # 描述符类 + 类装饰器	
    def data(self):
        return self.get_data(parse_form_data=True)
    def get_data(self, cache=True, as_text=False, parse_form_data=False):
        rv = getattr(self, "_cached_data", None)
        if rv is None:
            if parse_form_data:
                self._load_form_data()
            rv = self.stream.read()
            if cache:
                self._cached_data = rv
        if as_text:
            rv = rv.decode(self.charset, self.encoding_errors)
        return rv
    @cached_property
    def stream(self):
        _assert_not_shallow(self)
        return get_input_stream(self.environ)
    
class cached_property(property):	# 描述符类
    def __init__(self, func, name=None, doc=None):
        self.__name__ = name or func.__name__
        self.__module__ = func.__module__
        self.__doc__ = doc or func.__doc__
        self.func = func

    def __set__(self, obj, value):
        obj.__dict__[self.__name__] = value

    # self:<werkzeug.utils.cached_property object 
    # obj: <Request 'http://192.168.6.128:5000/' [GET]>
    def __get__(self, obj, type=None): 
        if obj is None:
            return self
        value = obj.__dict__.get(self.__name__, _missing)
        if value is _missing:
            value = self.func(obj)
            obj.__dict__[self.__name__] = value
        return value  
    
```

## (2) class Response分析

Response类的核心功能有两个，一个是通过一定的封装构造返回值，另一个是返回一个符合WSGI规范的函数。具体的实现比较简单不在详述。

```python
response = Response(text, mimetype='text/plain')
return response(environ, start_response)

# Response的init函数
def __init__(
    self,
    response=None,
    status=None,
    headers=None,
    mimetype=None,
    content_type=None,
    direct_passthrough=False,
)

# Response的call函数
def __call__(self, environ, start_response):
    app_iter, status, headers = self.get_wsgi_response(environ)
    start_response(status, headers)
    return app_iter

```

# 五、Map、Rule和MapAdapter

以一个Demo为例， 看下这三个类的使用。

```python
from wsgiref import simple_server

from werkzeug.routing import Map, Rule, HTTPException
from werkzeug.wrappers import Response, Request

url_map = Map([
    Rule('/test1', endpoint='test1'),
    Rule('/test2', endpoint='test2'),
    Rule('/<int:year>/<int:month>/', endpoint='blog/archive'),
])


def test1(request, **args):
    return Response('test1')


def test2(request, **args):
    return Response('test2')


views = {'test1': test1, 'test2': test2}


def application(environ, start_response):
    request = Request(environ)
    try:
        return url_map.bind_to_environ(environ).dispatch(
            lambda endpoint, args: views[endpoint](request, **args)
        )(environ, start_response)
    except HTTPException as e:
        return e(environ, start_response)


http_server = simple_server.make_server('0.0.0.0', 5000, application)
http_server.serve_forever()


```

- 应用程序的所有路由规则都使用一个Map对象管理，Map对象的主要参数是一个Rule数组。
- Rule包括url的规则和端点endpoint。
- 每个http请求使用Map对象的bind_to_environ得到一组urls(MapAdapter对象)。
- 使用urls的match方法匹配到endpoint和rule的url规则中定义的参数，例如:/[int:year](https://link.juejin.cn?target=undefined)/[int:month](https://link.juejin.cn?target=undefined)/会得到(year, month)这样2个参数的元组。
- 使用端点endpoint查找对应的handerl函数(Front-Control模式)。

Rule对象的构造函数和示例一样，主要是rule规则的string定义和监听函数的端点endpoint两个参数:

```python
class Rule(RuleFactory):
    
    def __init__(
        self,
        string: str,
        ...
        endpoint: t.Optional[str] = None,
        ...
        websocket: bool = False,
    ) -> None:
        self.rule = string		# /test1
        ...
        self.endpoint: str = endpoint  # type: ignore
        ...
        self.arguments = set()
```

继续看Map对象的构造函数:

```python
class Map:
    def __init__(
        self,
        rules: t.Optional[t.Iterable[RuleFactory]] = None,
        default_subdomain: str = "",
        charset: str = "utf-8",
        strict_slashes: bool = True,
        merge_slashes: bool = True,
        redirect_defaults: bool = True,
        converters: t.Optional[t.Mapping[str, t.Type[BaseConverter]]] = None,
        sort_parameters: bool = False,
        sort_key: t.Optional[t.Callable[[t.Any], t.Any]] = None,
        encoding_errors: str = "replace",
        host_matching: bool = False,
    ) -> None:
        self._rules: t.List[Rule] = []
        ...
        self.converters = self.default_converters.copy()
        ...
        for rulefactory in rules or ():
            self.add(rulefactory)
```

重头戏在Map对象的add方法:

```python
def add(self, rulefactory: RuleFactory) -> None:
    """Add a new rule or factory to the map and bind it.  Requires that the
    rule is not bound to another map.
    :param rulefactory: a :class:`Rule` or :class:`RuleFactory`
    """
    for rule in rulefactory.get_rules(self):
        rule.bind(self)
        self._rules.append(rule)
        self._rules_by_endpoint.setdefault(rule.endpoint, []).append(rule)
    self._remap = True
```

rule.bind主要工作就是对rule进行预先编译，提高查询时候的正则匹配速度, 这一部分比较复杂，我们暂时跳过，知道是将 `/<int:year>/<int:month>/<int:day>/` 这样的规则，编译生成对应的正则表达式即可。

请求的rule匹配过程是下面这样，首先从environ中解析出path，method和query_string三个重要的信息，生成一个MapAdapter对象:

```python
def bind_to_environ(
    self,
    environ: "WSGIEnvironment",
    server_name: t.Optional[str] = None,
    subdomain: t.Optional[str] = None,
) -> "MapAdapter":
    ...
    path_info = _get_wsgi_string("PATH_INFO")
    query_args = _get_wsgi_string("QUERY_STRING")
    default_method = environ["REQUEST_METHOD"]
    server_name = server_name.lower()
    try:
        server_name = _encode_idna(server_name)  # type: ignore
    except UnicodeError:
        raise BadHost()
    return MapAdapter(
        self,
        server_name,
        script_name,
        subdomain,
        url_scheme,
        path_info,
        default_method,
        query_args,
    )
```

然后调用MapAdapter对象的match方法:

```python
def match(
    self,
    path_info: t.Optional[str] = None,
    method: t.Optional[str] = None,
    return_rule: bool = False,
    query_args: t.Optional[t.Union[t.Mapping[str, t.Any], str]] = None,
    websocket: t.Optional[bool] = None,
    ) -> t.Tuple[t.Union[str, Rule], t.Mapping[str, t.Any]]:
    ...
    for rule in self.map._rules:
        try:
            rv = rule.match(path, method)
        except RequestPath as e:
            raise RequestRedirect(
                self.make_redirect_url(
                    url_quote(e.path_info, self.map.charset, safe="/:|+"),
                    query_args,
                )
            )
        except RequestAliasRedirect as e:
            raise RequestRedirect(
                self.make_alias_redirect_url(
                    path, rule.endpoint, e.matched_values, method, query_args
                )
            )
        if rv is None:
            continue
       ...
    return rule.endpoint, rv
```

match过程比较简单，就是对所有的rule进行循环，使用rule的math方法判断path是否和method匹配：

```python
def match(
    self, path: str, method: t.Optional[str] = None
) -> t.Optional[t.MutableMapping[str, t.Any]]:
    m = self._regex.search(path)
    if m is not None:
        groups = m.groupdict()
        ...
        result = {}
        for name, value in groups.items():
            try:
                value = self._converters[name].to_python(value)
            except ValidationError:
                return None
            result[str(name)] = value
        return result
```

- 使用正则表达式搜素path是否匹配

- 匹配上的rule将query_string解析出rule参数，这个过程由Converter处理，因为url上都是字符串，需要将字符串转换成具体的类型，比如int。

Converter种类如下表:

| 类型    | 名称             |
| ------- | ---------------- |
| default | UnicodeConverter |
| string  | UnicodeConverter |
| any     | AnyConverter     |
| path    | PathConverter    |
| int     | IntegerConverter |
| float   | FloatConverter   |
| uuid    | UUIDConverter    |



简单介绍一下NumberConverter，主要是其to_python方法, 判断是否符合极限值要求，然后强转成int类型数据:

```python
class NumberConverter(BaseConverter):
    regex = r"\d+"
    num_convert: t.Callable = int
    
    def to_python(self, value: str) -> t.Any:
        if self.fixed_digits and len(value) != self.fixed_digits:
            raise ValidationError()
        value = self.num_convert(value)
        if (self.min is not None and value < self.min) or (
            self.max is not None and value > self.max
        ):
            raise ValidationError()
        return value
    ...
```



Converter的使用可以配合业务函数理解, 对于 `/1001` 这样的URL，解析出其中的 `short_id=1001` 参数:



```python
# /1001
# Rule("/<short_id>", endpoint="follow_short_link"),
def on_follow_short_link(self, request, short_id):
    link_target = self.redis.get(f"url-target:{short_id}")
    if link_target is None:
        raise NotFound()
    self.redis.incr(f"click-count:{short_id}")
    return redirect(link_target)
```



http的路由处理还有一种使用前缀树实现的方案，比这里使用复杂度为 **N** 的一次循环算法要更高效，等以后讲解gin框架的时候再介绍