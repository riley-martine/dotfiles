#!/usr/bin/env fish

for i in (cat programs | string match -r '^[^#].*$')
    if not which $i > /dev/null
        echo "Can't find $i!"
    end
end
