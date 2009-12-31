#!/bin/bash
export CATALYST_ENGINE='HTTP::Prefork'
export DBIC_TRACE=1
export CATALYST_DEBUG=1
export ICYDEE_DOCS_WEB_PORT=3002
script/icd.pl -r -k

