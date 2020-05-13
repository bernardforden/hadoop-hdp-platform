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
$uri = URI->new("http://services.hadoop.local/logs/004daa78-6829-4b4c-b701-054cc493a3b7");

# POST {"application_id":"004daa78-6829-4b4c-b701-054cc493a3b7"}
# REP  {"session_id":"15bbf5b0-f7a3-401e-bd54-488d14e53e46","max_age":7150,"secure_hash_key":"9bffd3a9-084b-4c3e-ba82-d3930ff3b157"}
# secure_hash_code=MD5("/logs/004daa78-6829-4b4c-b701-054cc493a3b79bffd3a9-084b-4c3e-ba82-d3930ff3b157")=597ae0f3ae6c09ee65b5df2465c14936
# secure_hash_code=MD5("/streamFile/user/apps/004daa78-6829-4b4c-b701-054cc493a3b79bffd3a9-084b-4c3e-ba82-d3930ff3b157")=27e04c74a12c7401726791b08ef12ffd

timethese(-50, {
	ExternalLogService => sub {		
		$uri->query_form(json => '{"level":"DEBUG","index": ' . $req_count++ . ',"message":' . rand() . '}');		
		my $req = HTTP::Request->new( GET => $uri);
		$req->header("content-type" => "application/x-www-form-urlencoded");
		$req->header("cookie" => "session_id=15bbf5b0-f7a3-401e-bd54-488d14e53e46;application_id=004daa78-6829-4b4c-b701-054cc493a3b7;secure_hash_code=597ae0f3ae6c09ee65b5df2465c14936;");
		$async->add( $req );
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