package hdpauth;
use nginx;
use Data::Dumper;
use LWP::UserAgent;
use CGI qw/:standard/;
use CGI::Cookie;
use HTTP::Async;

$| = 1;

# global variable for logging asynchronously
$async = HTTP::Async->new;

sub auth {
	my $r = shift;
	my $cookieStr = lc $r->header_in("Cookie");	
	if ($cookieStr =~ /session_id/) {
		my $cgi = CGI->new();
		# create cookies returned from an external source
		%cookies = CGI::Cookie->parse($cookieStr);		
		# retrieve parameters from request Query or Cookie
		my $session_id = (defined $cookies{"session_id"})? $cookies{"session_id"}->value : $cgi->param("session_id");		
		my $application_id = (defined $cookies{"application_id"})? $cookies{"application_id"}->value : $cgi->param("application_id");
		my $secure_hash_code = (defined $cookies{"secure_hash_code"})? $cookies{"secure_hash_code"}->value : $cgi->param("secure_hash_code");

		hdpauth::DEBUG('{"uri": "' . $r->uri() . '", "session_id": "' . $session_id . '", "application_id": "' . $application_id . '", "secure_hash_code": "' . $secure_hash_code . '"}');

		if ( (defined $session_id and length $session_id) and 
			 (defined $application_id and length $application_id) and
			 (defined $secure_hash_code and length $secure_hash_code) ){
			my $ua = LWP::UserAgent->new;
			my $uri = URI->new("http://127.0.0.1:1605/auth/session/scope");
			$uri->query_form(request_uri => $r->uri(), secure_hash_code => $secure_hash_code);			
			my $req = HTTP::Request->new(HEAD => $uri);
			$req->header("content-type" => "application/json");
			$req->header("cookie" => "session_id=" . $session_id . ";application_id=" . $application_id);
			my $resp = $ua->request($req);
			if ($resp->is_success) {
				hdpauth::DEBUG('{"result": "' . $resp->status_line . '"}');
				return 1;
			}
			hdpauth::DEBUG('{"result": "' .  $resp->status_line . '", "message": "' . $resp->decoded_content . '"}');
		} else {
			my $message = "";
			if ( !(defined $application_id and length $application_id) ) { $message = "application_id "; }
			if ( !(defined $session_id and length $session_id) ) { $message = $message . "session_id "; }
			if ( !(defined $secure_hash_code and length $secure_hash_code) ) { $message = $message . "secure_hash_code"; }
			hdpauth::DEBUG('{"result": "500 Internal Error", "message": "Missing parameters - ' . $message . '"}');
		}		
	}
	return 0; #1:mockup-test-OK	#0:invalid session
}

sub DEBUG {
	my $message = shift;	
	my $uri = URI->new("http://localhost:2201/logs/sys-auth");
	$uri->query_form(json => '{"level":"DEBUG", "message":' . $message . '}');			
	$async->add( HTTP::Request->new( GET => $uri) );
}

__END__
