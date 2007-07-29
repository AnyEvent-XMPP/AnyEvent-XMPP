package Net::XMPP2::Ext::MUC::User;
use strict;
use Net::XMPP2::Namespaces qw/xmpp_ns/;
use Net::XMPP2::Event;
use Net::XMPP2::IM::Presence;
use Net::XMPP2::Util qw/split_jid/;

our @ISA = qw/Net::XMPP2::IM::Presence/;

=head1 NAME

Net::XMPP2::Ext::MUC::User - User class

=head1 SYNOPSIS

=head1 DESCRIPTION

This module represents a user (occupant) handle for a MUC.
This class is derived from L<Net::XMPP2::Presence> as a user has
also a presence within a room.

=head1 METHODS

=over 4

=item B<new (%args)>

=cut

sub new {
   my $this = shift;
   my $class = ref($this) || $this;
   my $self = $class->SUPER::new (@_);
   $self->init;
   $self
}

sub update {
   my ($self, $node) = @_;
   $self->SUPER::update ($node);
   my ($xuser) = $node->find_all ([qw/muc_user x/]);
   my $from = $node->attr ('from');
   my ($room, $srv, $nick) = split_jid ($from);

   my ($aff, $role, $stati);
   $stati = {};

   if ($xuser) {
      if (my ($item) = $xuser->find_all ([qw/muc_user item/])) {
         $aff  = $item->attr ('affiliation');
         $role = $item->attr ('role');
      }
   }
   $self->{nick}        = $nick;
   $self->{affiliation} = $aff;
   $self->{role}        = $role;
}

sub init {
   my ($self) = @_;
   $self->{connection} = $self->{room}->{muc}->{connection}
}

=item B<nick>

The nickname of the MUC user.

=cut

sub nick { $_[0]->{nick} }

=item B<affiliation>

The affiliation of the user.

=cut

sub affiliation { $_[0]->{affiliation} }

=item B<role>

The role of the user.

=cut

sub role { $_[0]->{role} }

=item B<room>

The L<Net::XMPP2::Ext::MUD::Room> this user is in.

=cut

sub room { $_[0]->{room} }

=back

=head1 AUTHOR

Robin Redeker, C<< <elmex at ta-sa.org> >>, JID: C<< <elmex at jabber.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2007 Robin Redeker, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
