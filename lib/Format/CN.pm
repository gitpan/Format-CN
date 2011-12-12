package Format::CN;
{
    $Format::CN::VERSION = '0.01';
}
use strict;
use warnings;
use Encode qw/encode decode is_utf8/;
use Sub::Exporter -setup => {exports => ['f']};
use Carp qw/carp croak/;

sub f {
    my %args = @_;
    my ($output, $perl_internal);
    my ($in,     $out);
    my $en = $args{encoding} || 'utf8';
    if ($args{output}) {
        open $out, ">:encoding($en)", $args{output} or die $!;
    } else {
        $out = *STDOUT;
    }

    if ($args{content}) {
        if (!$args{encoding}) {
            if (is_utf8($args{encoding})) {
                open $in, "<", \$args{content} or die $!;
            } else {
                open $in, "<:encoding(utf8)", \$args{content} or die $!;
            }
        } else {
            open $in, "<:encoding($args{encoding})", \$args{content}
              or die $!;
        }
        return _format($in, $out);
    } elsif ($args{file}) {
        $args{encoding} ||= 'utf8';
        open $in, "<:encoding($args{encoding})", $args{file} or die $!;
        return _format($in, $out);
    } else {
        return;
    }
}

sub _format($$) {
    my ($input_fh, $output_fh) = @_;
    my ($n_is_han, $p_is_han, $p_is_pun, $n_is_pun, $n_is_others);
    while (my $c = getc($input_fh)) {
        if ($c =~ /\p{han}/) {
            $n_is_han = 1;
            $n_is_pun = 0;
            $ENV{DEBUG_MATCH} && print "get han $c\n";
        } elsif ($c =~ /\p{p}/) {
            $n_is_han = 0;
            $n_is_pun = 1;
            $ENV{DEBUG_MATCH} && print "get punctuation $c\n";
        } elsif ($c =~ /\s/s) {
            $n_is_others = 1;
        } else {
            $n_is_han = 0;
            $n_is_pun = 0;
            $ENV{DEBUG_MATCH} && print "get others" . ord($c) . "\n";
        }
        (        defined $p_is_han
              && !$n_is_others
              && !$n_is_pun
              && ($n_is_han ^ $p_is_han)
              && !$p_is_pun)
          && print $output_fh " ";

        print $output_fh $c;
        $p_is_han = $n_is_han;
        $p_is_pun = $n_is_pun;
    }
    close $input_fh;
    close $output_fh;
}

1;

__END__


=pod 

=head1 NAME 

Format::CN - Format CN&EN pages for typesetting

=head1 VERSION

version 0.01

=head1 SYNOPSIS

    use Format::CN 'f';

    f(content => '中国Perl协会，http://www.perlchina.org', output => 'log');
    f(file => 'content.txt', encoding => 'utf8', output => \$string);

=head1 DESCRIPTION

本模块用来格式化中英混排之间的空格

=head1 AUTHOR

woosley.xu <woosley.xu@gmail.com>

=head1 COPYRIGHT & LICENSE

This software is copyright (c) 2011 by woosley.xu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
