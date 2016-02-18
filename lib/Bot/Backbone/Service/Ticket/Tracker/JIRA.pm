package Bot::Backbone::Service::Ticket::Tracker::JIRA;
use Moose;

with qw( Bot::Backbone::Service::Ticket::Tracker );

use JIRA::REST;

# ABSTRACT: ticket tracker lookups for JIRA

=head1 SYNOPSIS

    service jira_tickets => (
        service  => 'Ticket',
        trackers => [{
            type       => 'JIRA',
            uri        => 'http://company.atlassian.net/',
            username   => 'botuser',
            password   => 'secret',
            title      => 'Issue %{issue}s: %{summary}s',
            link       => 'https://company.atlassian.net/browse/%{issue}s',
            patterns   => [
                qr{(?<!/)\b(?<issue>[A-Za-z]+-\d+)\b},
                qr{(?<![\[])\b(?<schema>https:)//company\.atlassian\.net/browse/(?<issue>[A-Za-z]+-\d+)\b},
            ],
        }],
    );

=head1 DESCRIPTION

This works with L<Bot::Backbone::Service::Ticket> to perform JIRA ticket lookups and summaries.

=head1 ATTRIBUTES

=head2 uri

This is a required parameter that names the URI of your JIRA ticket tracker host.

=head2 username

This is the username to use for logging in to JIRA.

=head2 password

This is the password to use for logging in to JIRA.

=cut

has uri      => ( is => 'ro', isa => 'Str', required => 1 );
has username => ( is => 'ro', isa => 'Str', required => 1 );
has password => ( is => 'ro', isa => 'Str', required => 1 );

=head1 METHODS

=head2 lookup_issue

This is a very simple lookup by issue number that returns the summary field for the issue as the "summary" key and the looked up issue number as the "issue" key.

=cut

sub lookup_issue {
    my ($self, $number) = @_;
    my $jira = JIRA::REST->new($self->uri, $self->username, $self->password);
    my $issue = $jira->GET("/issue/$number");
    return {
        issue   => $number,
        summary => $issue->{fields}{summary},
    };
}

__PACKAGE__->meta->make_immutable;
