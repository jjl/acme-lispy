package Acme::Lispy;
use Acme::Lispy::Language;
use Filter::Util::Call;

sub import {
    my ($type) = @_;
    my ($ref) = [];
    filter_add(bless $ref);
}
sub filter {
    my ($self) = @_;
    my ($status);
    if (($status = filter_read()) > 0) {
	  my $lang = Acme::Lispy::Language->new;
	  $_ = $lang->go($_);
    }
    $status;
}
1;
__END__

=head1 NAME

Acme::Lispy - How not to write lisp in perl

=head1 SYNOPSIS

  use Acme::Lispy;
  (if 1) {
    (print "Marvel at my s-expressions!")
  } (elsif 0) {
    (let $x 1 $y 2)
    1 + 2
    (print "I am a thing of beauty")
  }

=head1 DESCRIPTION

Basically, this adds a lisp source filter on top of perl for no good reason whatsoever. I wouldn't use it. I'd be surprised if it even compiles, but the theory is sound.

=head1 COPYRIGHT

(c) 2014 James Laver

Public Domain.

=cut
