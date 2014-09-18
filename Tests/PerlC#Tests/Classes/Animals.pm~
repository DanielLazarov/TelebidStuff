package Animal;

sub new {
    my $class = shift;
    my $self = bless {}, $pkg;
    $self->initialize(@_);
    return $self;
}

sub makeSomeNoise {
	print "Silent Mode ON! \n";
}

sub initialize {
    my $self = shift;
    $self->{_name} = shift;
    $self->{_gender} = shift;
	$self->{_color} = shift;
	$self->{_age} = undef;
}

sub age {
	my ($self, $age) = @_;
	$self->{_age} = $age if defined($age);
	return $self->{_age};
}

sub name{
	my($self) = @_;
	return $self->{_name};
}

sub gender{
	my($self) = @_;
	return $self->{_gender};
}

sub color{
	my($self) = @_;
	return $self->{_color};
}

sub DESTROY
{	my($self) = @_;
    print $self->{_name} . " Died \n";
}

sub checkType {
	my($self) = @_;
	return ref $self;
}
package Cat;
our @ISA = "Animal";

sub new {
	my $class = shift;
	my $self = bless {}, $class;
	$self->initialize(@_);
	return $self;
}

sub initialize {
	my $self = shift;
	$self->SUPER::initialize(shift, shift, shift);
	$self->{_isNinja} = shift;
}

sub isNinja {
	my ($self, $is) = @_;
	$self->{_isNinja} = $is if defined($is);
	return $self->{_isNinja};
}

sub makeSomeNoise {
	print "Meouww! \n";
}

package Dog;
our @ISA = "Animal";

sub new {
	my $class = shift;
	my $self = bless {}, $class;
	$self->initialize(@_);
	return $self;
}

sub initialize {
	my $self = shift;
	$self->SUPER::initialize(shift, shift, shift);
	$self->{_type} = shift;
}

sub type {
	my ($self) = @_;
	return $self->{_type};
}

package Hamster;
our @ISA = "Animal";

sub new {
	my $class = shift;
	my $self = bless {}, $class;
	$self->initialize(@_);
	return $self;
}

sub initialize {
	my $self = shift;
	$self->SUPER::initialize(shift, shift, shift);
	$self->{_isEvil} = shift;
}

sub type {
	my ($self, $is) = @_;
	$self->{_isEvil} = $is if defined($is);
	return $self->{_isEvil};
}

sub makeSomeNoise {
	print "hrppp! \n";
}
1;
