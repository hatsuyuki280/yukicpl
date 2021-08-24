#!/bin/sh
echo "this case will return OK."
sleep 3
(return 0) && echo OK || echo Filed
echo "this case will return Filed."
sleep 3
(return 1) && echo OK || echo Filed