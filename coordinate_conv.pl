#!/usr/bin/perl

use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Feature;

# define subroutine to report mapped coordinate
# it will take slice, seq_start, seq_end, coordinate system to convert to, coordinate system version to convert to
sub report_same_region_human_chromosome_converted_coord
{
    # disable warning message for clarity of output
    no warnings 'uninitialized';

    my $slice = $_[0];
    my $seq_start = $_[1];
    my $seq_end = $_[2];
    my $new_cs = $_[3];
    my $new_cs_version = $_[4];
    
    # creating feature from slice
    my $feature_old_cs = new Bio::EnsEMBL::Feature(-start=>$seq_start, -end=>$seq_end, -strand=>1, -slice => $slice);
    
    # transform() will be undefined if new coordinate system crosses feature seq region
    # So, we will do project
    # printf("%s:%s to %s:%s mapping crosses seq region, using project to found mapping\n", 
    #     $feature_old_cs->slice()->coord_system()->name(), $feature_old_cs->slice()->coord_system()->version(), $new_cs,$new_cs_version);

    my $projection_new_cs = $feature_old_cs->project($new_cs, $new_cs_version);

    # to count how many seq can be mapped to new cs:new cs version to same region
    my $same_region_mapping_count = 0;
    while (my $seg = shift @{$projection_new_cs}) {
        my $clone = $seg->to_Slice();
        # adding $seq_start as seg will show coordinate relative to the seq start coordinate used to generate feature
        # -1 is done as 1-based coordinate system is used
        if ($clone->seq_region_name eq $feature_old_cs->seq_region_name()) {
            print "Features current coords ", $seq_start+$seg->from_start-1, '-',
                $seq_start+$seg->from_end-1, " project onto clone coords " .
                $clone->seq_region_name, ':', $clone->start, '-', $clone->end,
                $clone->strand, "\n";

            $same_region_mapping_count++;
        }
    }

    if ($same_region_mapping_count == 0) {
        printf("No mapping of %s:%s to %s:%s  is found to the same region for seq %d-%d\n", 
            $feature_old_cs->slice()->coord_system()->name(), $feature_old_cs->slice()->coord_system()->version(), 
            $new_cs, $new_cs_version, $seq_start, $seq_end);
    }
}


# check if argv contains necessary input
my ($chromosome_number, $start, $end, $new_cs, $new_cs_version) = @ARGV;

if (not defined $chromosome_number) {
    die "Provide <chromosome number>\nUsage: ./coordinate_conv.pl <chromosome number> <start coordinate in GRCh38> 
         <end coordinate in GRChh38> <new coordinate system name> <new coordinate version>\n";
}
if (not defined $start) {
    die "Provide <start coordinate in GRChh38>\nUsage: ./coordinate_conv.pl <chromosome number> <start coordinate in GRCh38> 
         <end coordinate in GRChh38> <new coordinate system name> <new coordinate version>\n";
}
if (not defined $end) {
    die "Provide <end coordinate in GRChh38>\nUsage: ./coordinate_conv.pl <chromosome number> <start coordinate in GRCh38> 
         <end coordinate in GRChh38> <new coordinate system name> <new coordinate version>\n";
}
if (not defined $new_cs) {
    die "Provide <new coordinate system name>\nUsage: ./coordinate_conv.pl <chromosome number> <start coordinate in GRCh38> 
         <end coordinate in GRChh38> <new coordinate system name> <new coordinate version>";
}
if (not defined $new_cs_version) {
    die "Provide <new coordinate version>\nUsage: ./coordinate_conv.pl <chromosome number> <start coordinate in GRCh38> 
         <end coordinate in GRChh38> <new coordinate system name> <new coordinate version>";
}

my $registry = 'Bio::EnsEMBL::Registry';
# db connection and data fetch
# we are taking GRCh38 human genome, which is latest genome assembly
$registry->load_registry_from_db(
	-host => 'ensembldb.ensembl.org',
	-user => 'anonymous',
);

my $slice_adaptor = $registry->get_adaptor('Human', 'Core', 'Slice');
my $slice_grch38 = $slice_adaptor->fetch_by_region('chromosome', $chromosome_number);
    
# report coordinate conversion
report_same_region_human_chromosome_converted_coord($slice_grch38, $start, $end, $new_cs, $new_cs_version);

