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

=head1 SYNOPSIS

 use Sorter::by_similarity;

 my $sorter = Sorter::by_similarity::gen_sorter(string => 'foo');
 my @sorted = $sorter->("food", "foolish", "foo", "bar"); #

 # or, in one go
 my @sorted = sort_by_similarity(0, 0, {string=>"foo"}, "food", "foolish", "foo", "bar");


=head1 DESCRIPTION


=head1 FUNCTIONS

=head2 gen_sorter_by_similarity

Usage:

 my $sorter = gen_sorter_by_similarity($is_reverse, $is_ci, \%args);

Will generate a sorter subroutine C<$sorter> which accepts list and will sort
them and return the sorted items. C<$is_reverse> is a bool, can be set to true
to generate a reverse sorter (least similar items will be put first). C<$is_ci>
is a bool, can be set to true to sort case-insensitively.

Arguments:

=over

=item * string

Str. Required. Reference string to be compared against each item.

=back

=head2 sort_by_similarity

Usage:

 my @sorted = sort_by_similarity($is_reverse, $is_ci, \%args, @items);

A shortcut to generate sorter and sort items with sorter in one go.

=cut
