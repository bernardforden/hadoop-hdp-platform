#! /usr/bin/perl -w
use Benchmark;
use HTTP::Async;
use LWP::UserAgent;
use CGI qw/:standard/;

print "Start timing benchmark\n";

$req_count = 0;
$rep_count = 0;
$succeeded = 0;

$async = HTTP::Async->new;
$uri = URI->new("http://localhost:2201/logs/test-logs");

timethese(-50, {
	InternalLogService => sub {		
		$uri->query_form(json => '{"level":"DEBUG","index": ' . $req_count++ . ',"message":' . rand() . '}');		
		$async->add( HTTP::Request->new( GET => $uri) );
		$async->poke;
	},	
});

print "Simulation waiting for completion. \n";

my $response = $async->wait_for_next_response( 10 );
$succeeded += $response->is_success? 1:0;	

while( $response ) {
	$rep_count++;
	$response = $async->wait_for_next_response( 10 );
	if ($response) {
		$succeeded += $response->is_success? 1:0;	
	}
}

while ( $async->not_empty ) { }

print "Simulation finished - Req:" . $req_count .  ", Rep:" . $rep_count . ", Succeeded:" . $succeeded . "\n";