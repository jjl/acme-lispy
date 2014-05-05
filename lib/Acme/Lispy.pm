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
