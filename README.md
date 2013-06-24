Rhubarb
=======

Introduction
------------

Rhubarb is a Ruby library which will connect Control-M to KFS via Control-M's 'OS' job type, and KFS's Batch Invoker.

Compatibility
-------------

Rhubarb is tested on

* **Ruby 1.9.3** on **Linux 3.0.0**

That is all. It's targetted for RHEL 5.3, which has not that Ruby, so it also requires something like [KSI](https://github.com/ua-eas/ksi) to be installed and working.

Roadmap
-------

* Email is not written yet.

Installation
------------

`git clone` this repository.

Contributing
------------

Please do! Contributing is easy. Please read the CONTRIBUTING.md document for more info. ... When it exists.

batch\_logger.sh Usage
------------------------

`batch_logger.sh` can be used in two ways: as a stand-alone script, and as a library to be sourced. The `bin/batch_logger.sh` script will log a line in a specific subdirectory of `$BATCH_HOME/logs`. Use it as follows...

`$BATCH_HOME` should be defined, and should be a valid directory with a `logs` directory inside. Inside that
`logs` directory can be other directories, each referencing a loosely-defined "batch table."

Then you may call `batch_logger.sh` in the following ways:

    batch_logger.sh BATCH_TABLE SEVERITY [MESSAGE...]
    batch_logger.sh BATCH_TABLE stamp [MESSAGE...]
    batch_logger.sh BATCH_TABLE HEADER [MESSAGE...]
    batch_logger.sh BATCH_TABLE [MESSAGE...]

Here are some examples:

    batch_logger.sh BATCH_TABLE  # logs a blank INFO message to a log file in
                                 # $BATCH_HOME/logs/BATCH_TABLE, creating the
                                 # $BATCH_TABLE.log file if it doesn't exist.
    batch_logger.sh BATCH_TABLE message with many words
                                 # logs an INFO message, "message with many words," to
                                 # that same logfile.
    batch_logger.sh BATCH_TABLE WARN messagey message
                                 # logs a WARN message, "messagy message," to that same
                                 # logfile.
    batch_logger.sh BATCH_TABLE stamp
                                 # adds a long timestamp (RFC-2822-formatted) to that
                                 # same logfile.
    batch_logger.sh BATCH_TABLE h2 This is a header
                                 # adds a Markdown h2 header (looks like "## This is a
                                 # header")

The accepted serverities are:

    TRACE, DEBUG, INFO, WARN, ERROR, FATAL

The accepted headers are: `h1, h2, h3, h4, h5, h6`

You are more-likely interested in using `batch_logger.sh` as a library. To do this,
source the library as follows:

    source lib/batch_logger.sh BATCH_TABLE

At this point, log4sh will be set to always log to `$BATCH_HOME/logs/BATCH_TABLE.log`.
Then you can just use the bash functions made available:

    batch_log [MESSAGE...]
    batch_log_severity SEVERITY [MESSAGE...]
    logger_trace [MESSAGE...]
    logger_debug [MESSAGE...]
    logger_info [MESSAGE...]
    logger_warn [MESSAGE...]
    logger_error [MESSAGE...]
    logger_fatal [MESSAGE...]
    logger_stamp [MESSAGE...]
    logger_h1 [MESSAGE...]
    logger_h2 [MESSAGE...]
    logger_h3 [MESSAGE...]
    logger_h4 [MESSAGE...]
    logger_h5 [MESSAGE...]
    logger_h6 [MESSAGE...]

Testing
-------

Ruby 1.9.x and Bundler are required for running the tests.

To install the libraries required for the tests, run `bundle`. To run the tests, run
`rake`.

To run one test script alone, run `rspec path/to/spec-script.rb`

Versioning
----------

Rhubarb follows [Semantic Versioning](http://semver.org/) (at least approximately).

Rhubarb version is available by ...

License
-------

Please see [LICENSE.md](LICENSE.md).

