#! /usr/bin/perl -w
use Benchmark;
# Part One Modules and parameters
use Parallel::ForkManager;
srand;

############# configruation part #######################
my $processes=30;
my $transactions=5000;
########################################################

my $commandlineargs=0;

# Part Four - openMosix related. unlocks this process and all its children
sub unlock { 

#open (OUTFILE,">/proc/self/lock") || 
#ie "Could not unlock myself!\n"; 
#print OUTFILE "0"; 

} 

unlock;

# Part Five - Here we connect to the DB and populate the tables with records
sub setup {
	print "setting up...\n"
}

# Part Six - Stress-testing the DB with parallel instances 

sub run {
	print "$forks.";
}

# Part Seven - Stress-testing the DB with parallel instances 

sub cleanup {
	print "cleanning up...\n"
}

############## main ######################

print "\nStarting the sevice stress test\n\n";

# check for commandline arguments
foreach $parm (@ARGV) {
	$commandlineargs++;
}
$parm=0;
if ($commandlineargs!=2) {

	# get values from the user
 
	print "How many clients do you want to simulate ? : ";
	$processes=<STDIN>;
	chomp($processes); # removes any trailing string that corresponds to the current value: #avoid \n on last field
	while ($processes !~ /\d{1,10}/){
		print "Invalidate input! Please try again.\n";
		print "How many clients do you want to simulate ? : ";

		$processes = <STDIN>;
		chomp($processes);
	}
	print "How many transactions per client do you want to simulate ? : ";
	$transactions=<STDIN>;
	chomp($transactions);

	while ($transactions !~ /\d{1,10}/){
		print "Invalidate input! Please try again.\n";
		print "How many transactions per client do you want to simulate ? : ";

		$transactions = <STDIN>;
		chomp($transactions);
	}
} else {
	# parse the values from the command line
 
	$processes = $ARGV[0];
	$transactions = $ARGV[1];

	if (($processes !~ /\d{1,10}/) or ($transactions !~ /\d{1,10}/)) {
		print ("Invalidate input! Please try again.\n");		
		exit -1;
	} else {
		print("got the values for the stress test from the command line\n");		
		print("processes = $processes\n");
		print("transactions = $transactions\n");
	}
}

# cleaning up old db
print("cleanup data test\n");

cleanup();

print("fill up data test\n");

setup();

# Part Seven
print("starting $processes processes\n");
my $pm = new Parallel::ForkManager($processes);

$pm->run_on_start(
	sub { my ($pid,$ident)=@_;
		print "started, pid: $pid\n";
	}
);

for ($forks=0; $forks<$processes; $forks++){
  $pm->start and next;
  run($forks);
  $pm->finish;
}

$pm->wait_all_children;
$pm->finish;

print "Start timing benchmark\n";

timethese(-10, {
	CreateSession => sub {
		print "Session Created.\n";
	},
	CheckSession => sub {
		print "Session OK.\n";
	},
	CheckScope => sub {
		print "Scope Granted.\n";
	},
	GetResource => sub {
		print "{\"foo\":\"bar\"}\n";
	},
	DeleteSession => sub {
		print "Session Removed.\n";
	},
});

print "Start comparing benchmark\n";

cmpthese(-10, {
	CreateSession => sub {
		print "Session Created.\n";
	},
	CheckSession => sub {
		print "Session OK.\n";
	},
	CheckScope => sub {
		print "Scope Granted.\n";
	},
	GetResource => sub {
		print "{\"foo\":\"bar\"}\n";
	},
	DeleteSession => sub {
		print "Session Removed.\n";
	},
});

print "Simulation finished\n";