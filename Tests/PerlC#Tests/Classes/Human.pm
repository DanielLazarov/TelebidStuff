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

#set and return
sub address {
    my ( $self, $address ) = @_;
    $self->{_address} = $address if defined($address);
    return $self->{_address};
}

sub job {
	my ($self, $job) = @_;
	$self->{_job} = $job if defined($job);
	return $self->{_job};
}

#return only
sub firstName {
    my( $self ) = @_;
    return $self->{_firstName};
}

sub flastName {
    my( $self ) = @_;
    return $self->{_lastName};
}

sub indefNum {
    my( $self ) = @_;
    return $self->{_indefNum};
}

sub gender {
    my( $self ) = @_;
    return $self->{_fgender};
}

1;
