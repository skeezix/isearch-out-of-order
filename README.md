# isearch-out-of-order
Adding an out of order multi word search for Emacs isearch

*Goals*

- leverage Emacs built in isearch-forward and isearch-backward line based search (usually C-s and C-r) without external packages required
- support for multiple word out of order search; search for 'foo bar' to find 'foo blah bar' and 'bar blah foo'

*Alternatives*

- swiper from the ivy package (especially after tweaking to 1 line completion, it can feel nearly like isearch) .. occasionally fails to work for me (probably my fault)
- ctrlf - more like Windows based ctrl-f search
- consult-line
- helm has some options
- occur and the many grep options
- many more!

*Examples*

- foo bar -> out of order search for 'foo anything bar' and 'bar anything foo'
- foo\ bar -> search for "foo bar" precisely

The code is pretty hackish but seems to work. It is made complicated by Emacs regex engine lacking positive lookahead so we can't just string
the tokens together with (=? booleans but instead have to twist "foo bar" into literally "foo.\*bar|bar.\*foo" ... which gets especially goofy
if you have many tokens; using 2 or 3 should work pretty well before the generated regex gets insane. (There are some alternative approachs..
visual-regex package lets you use external python for its regex engine, but I'm trying to avoid baggage here.)

*Installation*

Initial stab is just a code snippet; drop into your config, or inhale it into your config with 'require'
