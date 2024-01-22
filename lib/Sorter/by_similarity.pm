package Sorter::by_similarity;

use 5.010001;
use strict;
use warnings;

use Text::Levenshtein::XS;

# AUTHORITY
# DATE
# DIST
# VERSION

sub meta {
    return +{
        v => 1,
        args => {
            string => {schema=>'str*', req=>1},
            reverse => {schema => 'bool*'},
            ci => {schema => 'bool*'},
        },
    };
}

sub gen_sorter {
    my %args = @_;

    my $reverse = $args{reverse};
    my $ci = $args{ci};

    sub {
        my @items = @_;
        my @distances;
        if ($ci) {
            @distances = map { Text::Levenshtein::XS::distance($args{string}, $_) } @items;
        } else {
            @distances = map { Text::Levenshtein::XS::distance(lc($args{string}), (lc $_)) } @items;
        }

        map { $items[$_] } sort {
            ($reverse ? $distances[$b] <=> $distances[$a] : $distances[$a] <=> $distances[$b]) ||
                ($reverse ? $b <=> $a : $a <=> $b)
            } 0 .. $#items;
    };
}

1;
# ABSTRACT: Sort by most similar to a reference string

=for Pod::Coverage ^(meta|gen_sorter)$

=head1 SYNOPSIS

 use Sorter::by_similarity;

 my $sorter = Sorter::by_similarity::gen_sorter(string => 'foo');
 my @sorted = $sorter->("food", "foolish", "foo", "bar"); #

 # or, in one go
 my @sorted = sort_by_similarity(0, 0, {string=>"foo"}, "food", "foolish", "foo", "bar");


=head1 DESCRIPTION

=cut
