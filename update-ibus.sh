# docker create --name ibus-extract ibus:latest

# docker cp ibus-extract:/usr/local/lib/gtk-2.0/2.10.0/immodules/im-ibus.so ~/im-ibus.so2
# cd /usr/lib/x86_64-linux-gnu/gtk-2.0/2.10.0/immodules/
# cp im-ibus.so im-ibus.so.bak
# cp ~/im-ibus.so2 im-ibus.so
# /usr/lib/x86_64-linux-gnu/libgtk2.0-0/gtk-query-immodules-2.0 --update-cache

docker cp ibus-extract:/usr/local/lib/gtk-3.0/3.0.0/immodules/im-ibus.so ~/im-ibus.so3
cd /usr/lib/x86_64-linux-gnu/gtk-3.0/3.0.0/immodules/
cp im-ibus.so im-ibus.so.bak
cp ~/im-ibus.so3 im-ibus.so
/usr/lib/x86_64-linux-gnu/libgtk-3-0/gtk-query-immodules-3.0 --update-cache

docker cp ibus-extract:/usr/local/lib/gtk-4.0/4.0.0/immodules/libim-ibus.so ~/im-ibus.so4
cd /usr/lib/x86_64-linux-gnu/gtk-4.0/4.0.0/immodules/
cp libim-ibus.so libim-ibus.so.bak
cp ~/im-ibus.so4 libim-ibus.so
