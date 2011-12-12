use Test::More tests => 1;    # last test to print
use Format::CN 'f';
f(file => 't/t.pod', encoding => 'utf8', output => \$string);
chomp $string;
cmp_ok($string, "eq", "测试 POD::CN。本 pod 用来测试", "comp");
