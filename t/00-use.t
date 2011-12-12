use strict;
use warnings;
use Test::More tests => 4;

BEGIN {
    use_ok("Format::CN", 'f');
}
use File::Temp 'tempfile';
my ($fh, $filename) = tempfile();
f(content => '你好me未来', encode => 'utf8', output => $filename);
my $a = do { local $/, <$fh> };
cmp_ok("你好 me 未来", 'eq', $a);
my $string;
f(content => '你好，me未来', output => \$string);
cmp_ok("$string", 'eq', "你好，me 未来");
f(  content => '中国Perl协会，http://www.perlchina.org',
    output  => \$string
);
cmp_ok("$string", 'eq', "中国 Perl 协会，http://www.perlchina.org");
