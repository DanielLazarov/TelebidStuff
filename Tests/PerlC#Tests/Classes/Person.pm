package Human;

sub new
{
	my $class = shift;
	my $self = {
		_firstName 	=> shift,
		_lastName 	=> shift,
		_gender		=> shift,
		_indefNum	=> shift
	};
	$self->{_address} = undef;
	$self->{_job} = undef;
	bless $self, $class;
	return $self;
}

sub setAddress {
    my ( $self, $address ) = @_;
    $self->{_address} = $address if defined($address);
    return $self->{_address};
}

sub setJob {
	my ($self, $job) = @_;
	$self->{_job} = $job if defined($job);
	return $self->{_job};
}

sub getFirstName {
    my( $self ) = @_;
    return $self->{_firstName};
}
1;
