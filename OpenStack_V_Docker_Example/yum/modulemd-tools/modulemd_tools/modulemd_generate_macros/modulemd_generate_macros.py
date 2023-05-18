#!/usr/bin/python3

"""
Generate module-build-macros SRPM package
See https://github.com/rpm-software-management/modulemd-tools/issues/10
See https://pagure.io/fm-orchestrator/issue/1217
"""

import os
import sys
import contextlib
import locale
import datetime
import textwrap
import tempfile
import glob
import logging
import subprocess
import argparse
from modulemd_tools.modulemd_tools.yaml import _yaml2stream, load


log = logging.getLogger("MBS")


def generate_module_build_macros_spec(mmd, disttag, td, conflicts_file=None):
    name = "module-build-macros"
    version = "0.1"
    release = "1"
    with set_locale(locale.LC_TIME, "C"):
        today = datetime.date.today().strftime("%a %b %d %Y")

    conflicts = ""
    if conflicts_file:
        with open(conflicts_file, "r") as f:
            conflicts = f.read()

    spec_content = textwrap.dedent("""
        %global dist {disttag}
        %global modularitylabel {module_name}:{module_stream}:{module_version}:{module_context}
        %global _module_name {module_name}
        %global _module_stream {module_stream}
        %global _module_version {module_version}
        %global _module_context {module_context}

        Name:       {name}
        Version:    {version}
        Release:    {release}%dist
        Summary:    Package containing macros required to build generic module
        BuildArch:  noarch

        Group:      System Environment/Base
        License:    MIT
        URL:        http://fedoraproject.org

        Source1:    macros.modules

        {filter_conflicts}

        %description
        This package is used for building modules with a different dist tag.
        It provides a file /usr/lib/rpm/macros.d/macro.modules and gets read
        after macro.dist, thus overwriting macros of macro.dist like %%dist
        It should NEVER be installed on any system as it will really mess up
        updates, builds, ....


        %build

        %install
        mkdir -p %buildroot/etc/rpm 2>/dev/null |:
        cp %SOURCE1 %buildroot/etc/rpm/macros.zz-modules
        chmod 644 %buildroot/etc/rpm/macros.zz-modules


        %files
        /etc/rpm/macros.zz-modules



        %changelog
        * {today} Fedora-Modularity - {version}-{release}{disttag}
        - autogenerated macro by Module Build Service (MBS)
    """).format(
        disttag=disttag,
        today=today,
        name=name,
        version=version,
        release=release,
        module_name=mmd.get_module_name(),
        module_stream=mmd.get_stream_name(),
        module_version=mmd.get_version(),
        module_context=mmd.get_context(),
        filter_conflicts=conflicts,
    )
    fd = open(os.path.join(td, "%s.spec" % name), "w")
    fd.write(spec_content)
    fd.close()


def generate_module_build_macros_source(mmd, disttag, td):
    modulemd_macros = ""
    buildopts = mmd.get_buildopts()
    if buildopts:
        modulemd_macros = buildopts.get_rpm_macros() or ""

    macros_content = textwrap.dedent("""
        # General macros set by MBS

        %dist {disttag}
        %modularitylabel {module_name}:{module_stream}:{module_version}:{module_context}
        %_module_build 1
        %_module_name {module_name}
        %_module_stream {module_stream}
        %_module_version {module_version}
        %_module_context {module_context}

        # Macros set by module author:

        {modulemd_macros}
    """).format(
        disttag=disttag,
        module_name=mmd.get_module_name(),
        module_stream=mmd.get_stream_name(),
        module_version=mmd.get_version(),
        module_context=mmd.get_context(),
        modulemd_macros=modulemd_macros,
    )
    sources_dir = os.path.join(td, "SOURCES")
    os.mkdir(sources_dir)
    fd = open(os.path.join(sources_dir, "macros.modules"), "w")
    fd.write(macros_content)
    fd.close()


def generate_module_build_macros_srpm(mmd, disttag, td, conflicts_file=None):
    name = "module-build-macros"
    sources_dir = os.path.join(td, "SOURCES")

    generate_module_build_macros_spec(mmd, disttag, td, conflicts_file)
    generate_module_build_macros_source(mmd, disttag, td)

    log.debug("Building %s.spec" % name)

    # We are not interested in the rpmbuild stdout...
    null_fd = open(os.devnull, "w")
    execute_cmd(
        [
            "rpmbuild",
            "-bs",
            "%s.spec" % name,
            "--define",
            "_topdir %s" % td,
            "--define",
            "_sourcedir %s" % sources_dir,
        ],
        cwd=td,
        stdout=null_fd,
    )
    null_fd.close()
    sdir = os.path.join(td, "SRPMS")
    srpm_paths = glob.glob("%s/*.src.rpm" % sdir)
    assert len(srpm_paths) == 1, "Expected exactly 1 srpm in %s. Got %s" % (sdir, srpm_paths)

    log.debug("Wrote srpm into %s" % srpm_paths[0])
    return srpm_paths[0]


# ------------------------------------------------------------------------------
# Copy-pasted functions from https://pagure.io/fm-orchestrator
# @TODO Figure out what to do with it

@contextlib.contextmanager
def set_locale(*args, **kwargs):
    saved = locale.setlocale(locale.LC_ALL)
    yield locale.setlocale(*args, **kwargs)
    locale.setlocale(locale.LC_ALL, saved)


def execute_cmd(args, stdout=None, stderr=None, cwd=None):
    """
    Executes command defined by `args`. If `stdout` or `stderr` is set to
    Python file object, the stderr/stdout output is redirecter to that file.
    If `cwd` is set, current working directory is set accordingly for the
    executed command.

    :param args: list defining the command to execute.
    :param stdout: Python file object to redirect the stdout to.
    :param stderr: Python file object to redirect the stderr to.
    :param cwd: string defining the current working directory for command.
    :raises RuntimeError: Raised when command exits with non-zero exit code.
    """
    out_log_msg = ""
    if stdout and hasattr(stdout, "name"):
        out_log_msg += ", stdout log: %s" % stdout.name
    if stderr and hasattr(stderr, "name"):
        out_log_msg += ", stderr log: %s" % stderr.name

    log.info("Executing the command \"%s\"%s" % (" ".join(args), out_log_msg))
    proc = subprocess.Popen(args, stdout=stdout, stderr=stderr, cwd=cwd)
    out, err = proc.communicate()

    if proc.returncode != 0:
        err_msg = "Command '%s' returned non-zero value %d%s" % (args, proc.returncode, out_log_msg)
        raise RuntimeError(err_msg)
    return out, err


# ------------------------------------------------------------------------------

def get_arg_parser():
    name = "modulemd-generate-macros"
    description = ("Generate `module-build-macros` SRPM package, which is a "
                   "central piece for building modules. It should be present "
                   "in the buildroot before any other module packages are "
                   "submitted to be built.")
    parser = argparse.ArgumentParser(name, description=description)
    parser.add_argument(
        "yaml",
        help="Path to modulemd YAML file "
    )
    parser.add_argument(
        "--disttag",
        required=False,
        help="Disttag"
    )
    parser.add_argument(
        "--conflicts-from-file",
        required=False,
        help=("Path to a file containing conflicts definitions and their "
              "reasoning. Content of this file gets simply pasted into the "
              "specfile")
    )
    return parser


def main():
    parser = get_arg_parser()
    args = parser.parse_args()

    disttag = args.disttag
    if not disttag:
        disttag = "%{?dist}"

    try:
        mmd = _yaml2stream(load(args.yaml))
    except RuntimeError as ex:
        print("Failed to parse {}".format(args.yaml))
        print("Make sure it is a valid modulemd YAML file\n")
        print("Hint: {}".format(str(ex)))
        sys.exit(1)

    try:
        td = tempfile.mkdtemp(prefix="module_build_service-build-macros")
        srpm = generate_module_build_macros_srpm(
            mmd, disttag, td, conflicts_file=args.conflicts_from_file)
        print(srpm)
    except RuntimeError as ex:
        print("\nFailed to generate module-build-macros SRPM package\n")
        print("{0}\n".format(str(ex)))
        print("Please review {}/module-build-macros.spec".format(td))
        sys.exit(1)


if __name__ == "__main__":
    main()
