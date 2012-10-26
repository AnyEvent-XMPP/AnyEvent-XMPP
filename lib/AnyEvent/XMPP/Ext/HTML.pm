package AnyEvent::XMPP::Ext::HTML;
use AnyEvent::XMPP::Namespaces qw/set_xmpp_ns_alias xmpp_ns/;
use AnyEvent::XMPP::Ext;
use strict;

our @ISA = qw/AnyEvent::XMPP::Ext/;

=head1 NAME

AnyEvent::XMPP::Ext::HTML - XEP-0071: XHTML-IM (Version 1.4)

=head1 SYNOPSIS

   my $con = AnyEvent::XMPP::Connection->new (...);
   $con->add_extension (my $disco = AnyEvent::XMPP::Ext::Disco->new);
   $con->add_extension (AnyEvent::XMPP::Ext::HTML->new (disco => $disco));

   $con->send_message (
      body => "This is plain text.",
      html => "This is <em>XHTML</em>.",
   );

=head1 DESCRIPTION

An implementation of XEP-0071: XHTML-IM for HTML-formatted messages.

=head1 METHODS

=over 4

=item B<new (%args)>

Creates a new extension handle.  It takes an optional C<disco> argument which
is a C<AnyEvent::XMPP::Ext::Disco> object for which this extension will be
enabled.

=cut

sub new {
   my $this = shift;
   my $class = ref($this) || $this;
   my $self = bless { @_ }, $class;
   $self->init;
   $self
}

sub disco_feature { xmpp_ns ('xhtml_im') }

sub init {
   my ($self) = @_;

   set_xmpp_ns_alias (xhtml_im => 'http://jabber.org/protocol/xhtml-im');
   set_xmpp_ns_alias (xhtml => 'http://www.w3.org/1999/xhtml');

   if (defined $self->{disco}) {
      $self->{disco}->enable_feature ($self->disco_feature);
   }

   $self->{cb_id} = $self->reg_cb (
      send_message_hook => sub {
         my ($self, $con, $id, $to, $type, $attrs, $create_cb) = @_;

         my $html = $attrs->{html};
         push @$create_cb, sub {
            my ($w) = @_;

            $w->addPrefix (xmpp_ns ('xhtml_im'), '');
            $w->startTag ([xmpp_ns ('xhtml_im'), 'html']);
            if (ref ($html) eq 'HASH') {
               for (keys %$html) {
                  $w->addPrefix (xmpp_ns ('xhtml'), '');
                  $w->startTag ([xmpp_ns ('xhtml'), 'body'], ($_ ne '' ? ([xmpp_ns ('xml'), 'lang'] => $_) : ()));
                  $w->raw ($html->{$_});
                  $w->endTag;
               }
            } else {
               $w->addPrefix (xmpp_ns ('xhtml'), '');
               $w->startTag ([xmpp_ns ('xhtml'), 'body']);
               $w->raw ($html);
               $w->endTag;
            }
            $w->endTag;
         };
      },
   );
}

sub DESTROY {
   my ($self) = @_;
   $self->unreg_cb ($self->{cb_id})
}

=back

=head1 CAVEATS

HTML messages are not validated nor escaped, so it is your responsibility to
use valid XHTML-IM tags and to close them properly.  It is particularly
important for a client to sanitize input from end users because specially
crafted messages can cause the sending of arbitrary XMPP stanzas, which may be
a security hazard in some cases.

=head1 AUTHOR

Charles McGarvey, C<< <chazmcgarvey at brokenzipper.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2007, 2008 Robin Redeker, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
