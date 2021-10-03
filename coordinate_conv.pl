#!/usr/bin/perl

use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Feature;

# define subroutine to report mapped coordinate
# it will take slice, seq_start, seq_end, coordinate system to convert to, coordinate system version to convert to
sub report_human_chromosome_converted_coord
{
    my $slice = $_[0];
    my $seq_start = $_[1];
    my $seq_end = $_[2];
    my $new_cs = $_[3];
    my $new_cs_version = $_[4];
    
    # we are only considering human genome
    my $feature_old_cs = new Bio::EnsEMBL::Feature(-start=>$seq_start, -end=>$seq_end, -slice => $slice);
    my $tranform_new_cs = $feature_old_cs->transform($new_cs, $new_cs_version);
    # transform will be undefined if new coordinate system crosses seq region
    # in that case, we will do project
    if (not defined $transform_new_cs) {
        printf("%s,%s mapping crosses seq region\n", $new_cs,$new_cs_version);
        my $projection_new_cs = $feature_old_cs->project($new_cs, $new_cs_version);

        while (my $seg = shift @{$projection_new_cs}) {
          my $clone = $seg->to_Slice();
          print "Features current coords ", $seg->from_start, '-',
            $seg->from_end, " project onto clone coords " .
            $clone->seq_region_name, ':', $clone->start, '-', $clone->end,
            $clone->strand, "\n";
        }
    }
    else {
        print "Features current coords ", $transform_new_cs->from_start, '-',
            $transform_new_cs->from_end, " project onto coords " .
            $transform_new_cs->seq_region_name, ':', $transform_new_cs->start, '-', $transform_new_cs->end,
            $transform_new_cs->strand, "\n";
    }
    # from experiment it seems transform causes feature to cross seq region, so using project    
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
report_human_chromosome_converted_coord($slice_grch38, $start, $end, $new_cs, $new_cs_version);

