#!/bin/sh

###############################################################################
# Install packages                                                            #
###############################################################################

if test ! $(which yolog)
then
  pip install yolog
fi

if test ! $(which dom)
then
  pip install dom
fi

if test ! $(which xmlformatter)
then
  pip install xmlformatter
fi

if test ! $(which pjson)
then
  pip install pjson
fi

pip install --upgrade pip
pip install --upgrade pip; pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U
