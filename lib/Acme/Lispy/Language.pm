package Acme::Lipsy::Language;

use Moo;

sub parse_string {
  my ($self,$input) = @_;
  if ($input =~ /^(".*(?<!\\)")(.*)$/) {
	my ($str, $rest) = ($1, $2);
	return ({type => 'string', value =>  $str}, $rest);
  } else {
	die("Unterminated string");
  }
}
sub parse_quote {
  my ($self, $input) = @_;
  $input =~ s/^'//;
  my ($thing, $rest) = $self->parse_one($input);
  return ({type => 'quote', value => $thing}, $rest);
}
sub parse_atom {
  my ($self, $input) = @_;
  $input =~ /^([^()\S]+)(.*)/;
  return ({type => 'atom', value => $1}, $2);
}
sub parse_list {
  my ($self, $input) = @_;
  my @items;
  my ($item, $rest);
  $input =~ s/^\(//;
  while ($input !~ /^\)/) {
	($item ,$rest) = $self->parse_one($input);
	push @items, $item;
  }
  return ({type => 'list', value => []}, $rest) unless @items;
  if ($items[0]->{type} eq 'atom') {
	if ($items[0]->{value} eq 'quote') {
	  die("Too many arguments to quote") unless @items == 2;
	  return ({type => 'quote', value => $items[1]}, $rest);
	} elsif ($items[0]->{value} eq 'let') else {
	  die("Uneven number of bindings in let") unless (@items % 2) == 1;
	  shift @items;
	  return ({type => 'let', value => [@items]}, $rest);
	} else {
	  return ({type => 'list', value => [@items]}, $rest);
	}
	return ({type => 'list', value => [@items]}, $rest);
  }
}
sub parse_one {
  my ($self, $input) = @_;
  $input =~ s/^\s+//;
  return $self->parse_string($input)
	if $input =~ /^"/;
  return $self->parse_list($input)
	if $input =~ /^\(/;
  return $self->parse_quote($input)
	if $input =~ /^'/;
  return $self->parse_atom($input);
}
sub parse {
  my ($self, $input) = @_;
  my $rest = $input;
  my $item;
  my @ret;
  while ($rest) {
	($item, $rest) = $self->parse_one($rest);
	push @ret, $item;
  }
  return @ret;
}

sub transpile {
  my ($self, @ast) = @_;
  my @ret;
  foreach my $thing (@ast) {
	if ($thing->{type} eq 'string') {
	  push @ret, $thing->{value};
	} elsif ($thing->{type} eq 'atom') {
	  push @ret, $thing->{value};
	} elsif ($thing->{type} eq 'let') {
	  my @working = @{$thing->{value}};
	  my @ret2;
	  while (@working) {
		my $key = shift;
		my $value = shift;
		push @ret2, "$key = $value";
	  }
	  push @ret, join ";" @ret2;
	} elsif ($thing->{type} eq 'quote') {
	  # No, this really isn't what quote does.
	  # Also, I never wrote this code.
	  push @ret, "sub {" . $thing->{value} . "}";
	} elsif ($thing->{type} eq 'list') {
	  if (@{$thing->{value}}) {
		my $subname = $thing->{value}->[0]->{value};
		my @args = @{$thing->{value}};
		shift @args;
		my $args = join ", ", map { $_->{value} } @args;
		push @ret, $subname . "(" . $args . ")";
	  } else {
		# Just to fuck with people.
		push @ret, "[]";
	  }
	}
  }
  return join " ", @ret;
}

sub go {
  my ($self, $input) = @_;
  return $self->transpile($self->parse($input));
}

__PACKAGE__->meta->make_immutable;
__END__
