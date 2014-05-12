=head1 LICENSE

Copyright [1999-2014] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut


=head1 CONTACT

  Please email comments or questions to the public Ensembl
  developers list at <http://lists.ensembl.org/mailman/listinfo/dev>.

  Questions may also be sent to the Ensembl help desk at
  <http://www.ensembl.org/Help/Contact>.

=head1 NAME

  Bio::EnsEMBL::Compara::PipeConfig::ProteinTrees_conf

=head1 DESCRIPTION

    The PipeConfig file for ProteinTrees pipeline that should automate most of the pre-execution tasks.

=head1 SYNOPSIS

    #1. update ensembl-hive, ensembl and ensembl-compara GIT repositories before each new release

    #2. you may need to update 'schema_version' in meta table to the current release number in ensembl-hive/sql/tables.sql

    #3. make sure that all default_options are set correctly

    #4. Run init_pipeline.pl script:
        init_pipeline.pl Bio::EnsEMBL::Compara::PipeConfig::ProteinTrees_conf -password <your_password> -mlss_id <your_current_PT_mlss_id>

    #5. Sync and loop the beekeeper.pl as shown in init_pipeline.pl's output

=head1 AUTHORSHIP

Ensembl Team. Individual contributions can be found in the GIT log.

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with an underscore (_)

=cut

package Bio::EnsEMBL::Compara::PipeConfig::ProteinTrees_conf;

use strict;
use warnings;


use base ('Bio::EnsEMBL::Compara::PipeConfig::ComparaGeneric_conf');


sub default_options {
    my ($self) = @_;

    return {
        %{$self->SUPER::default_options},   # inherit the generic ones

    # parameters that are likely to change from execution to another:
        # It is very important to check that this value is current (commented out to make it obligatory to specify)
        #'mlss_id'               => 40077,
        # It defaults to Bio::EnsEMBL::ApiVersion::software_version(): you're unlikely to change the value
        #'ensembl_release'       => 68,
        # You can add a letter to distinguish this run from other runs on the same release
        'rel_with_suffix'       => $self->o('ensembl_release')."",
        # names of species we don't want to reuse this time
        'do_not_reuse_list'     => [ ],
        'method_link_dump_file' => $self->o('ensembl_cvs_root_dir').'/ensembl-compara/sql/method_link.txt',

    # custom pipeline name, in case you don't like the default one
        #'pipeline_name'        => 'protein_trees_'.$self->o('rel_with_suffix'),
        # Tag attached to every single tree
        'division'              => undef,

    # dependent parameters: updating 'work_dir' should be enough
        #'work_dir'              => '/lustre/scratch101/ensembl/'.$self->o('ENV', 'USER').'/protein_trees_'.$self->o('rel_with_suffix'),
        'fasta_dir'             => $self->o('work_dir') . '/blast_db',  # affects 'dump_subset_create_blastdb' and 'blastp'
        'cluster_dir'           => $self->o('work_dir') . '/cluster',
        'dump_dir'              => $self->o('work_dir') . '/dumps',
        'hmmlib_dir'            => $self->o('work_dir') . '/hmmlib',

    # "Member" parameters:
        'allow_ambiguity_codes'     => 0,
        'allow_pyrrolysine'         => 0,
        # highest member_id for a protein member
        'protein_members_range'     => 100000000,

    # blast parameters:
        'blast_params'              => '-seg no -max_hsps_per_subject 1 -use_sw_tback -num_threads 1',

    # clustering parameters:
        # affects 'hcluster_dump_input_per_genome'
        'outgroups'                     => {},
        # (half of the previously used 'clutering_max_gene_count=1500) affects 'hcluster_run'
        'clustering_max_gene_halfcount' => 750,

    # tree building parameters:
        'use_raxml'                 => 0,
        'use_notung'                => 0,
        'treebreak_gene_count'      => 400,     # affects msa_chooser
        'mafft_gene_count'          => 200,     # affects msa_chooser
        'mafft_runtime'             => 7200,    # affects msa_chooser

    # species tree reconciliation
        # you can define your own species_tree for 'treebest'. It can contain multifurcations
        'species_tree_input_file'   => undef,
        # you can define your own species_tree for 'notung'. It *has* to be binary
        'binary_species_tree_input_file'   => undef,

    # homology_dnds parameters:
        # used by 'homology_dNdS'
        'codeml_parameters_file'    => $self->o('ensembl_cvs_root_dir').'/ensembl-compara/scripts/pipeline/protein_trees.codeml.ctl.hash',
        'taxlevels'                 => [],
        # affects 'group_genomes_under_taxa'
        'filter_high_coverage'      => 0,

    # mapping parameters:
        'do_stable_id_mapping'      => 0,
        'do_treefam_xref'           => 0,
        # The TreeFam release to map to
        'tf_release'                => undef,

    # executable locations:
        #'hcluster_exe'              => '/software/ensembl/compara/hcluster/hcluster_sg',
        #'mcoffee_home'              => '/software/ensembl/compara/tcoffee/Version_9.03.r1318/',
        #'mafft_home'                => '/software/ensembl/compara/mafft-7.113/',
        #'treebest_exe'              => '/software/ensembl/compara/treebest.doubletracking',
        #'notung_jar'                => '/software/ensembl/compara/Notung-2.6/Notung-2.6.jar',
        #'quicktree_exe'             => '/software/ensembl/compara/quicktree_1.1/bin/quicktree',
        #'hmmer2_home'               => '/software/ensembl/compara/hmmer-2.3.2/src/',
        #'codeml_exe'                => '/software/ensembl/compara/paml43/bin/codeml',
        #'ktreedist_exe'             => '/software/ensembl/compara/ktreedist/Ktreedist.pl',
        #'blast_bin_dir'             => '/software/ensembl/compara/ncbi-blast-2.2.28+/bin',
        #'pantherScore_path'         => '/software/ensembl/compara/pantherScore1.03',
        #'trimal_exe'                => '/software/ensembl/compara/src/trimAl/source/trimal',
        #'raxml_exe'                 => '/software/ensembl/compara/raxml/standard-RAxML-8.0.19/raxmlHPC-SSE3',

    # HMM specific parameters (set to 0 or undef if not in use)
       # List of directories that contain Panther-like databases (with books/ and globals/)
       # It requires two more arguments for each file: the name of the library, and whether subfamilies should be loaded
       'panther_like_databases'  => [],
       #'panther_like_databases'  => [ ["/lustre/scratch110/ensembl/mp12/panther_hmms/PANTHER7.2_ascii", "PANTHER7.2", 1] ],

       # List of MultiHMM files to load (and their names)
       #'multihmm_files'          => [ ["/lustre/scratch110/ensembl/mp12/pfamA_HMM_fs.txt", "PFAM"] ],
       'multihmm_files'          => [],

       # Dumps coming from InterPro
       'panther_annotation_file'    => '/dev/null',
       #'panther_annotation_file' => '/nfs/nobackup2/ensemblgenomes/ckong/workspace/buildhmmprofiles/panther_Interpro_annot_v8_1/loose_dummy.txt',

    # hive_capacity values for some analyses:
        #'reuse_capacity'            =>   3,
        #'blast_factory_capacity'    =>  50,
        #'blastp_capacity'           => 900,
        #'blastpu_capacity'          => 150,
        #'mcoffee_capacity'          => 600,
        #'split_genes_capacity'      => 600,
        #'trimal_capacity'           => 100,
        #'treebest_capacity'         => 400,
        #'raxml_capacity'            => 400,
        #'ortho_tree_capacity'       => 200,
        #'ortho_tree_annot_capacity' => 300,
        #'quick_tree_break_capacity' => 100,
        #'build_hmm_capacity'        => 200,
        #'ktreedist_capacity'        => 150,
        #'merge_supertrees_capacity' => 100,
        #'other_paralogs_capacity'   => 100,
        #'homology_dNdS_capacity'    => 200,
        #'qc_capacity'               =>   4,
        #'hc_capacity'               =>   4,
        #'HMMer_classify_capacity'   => 400,
        #'loadmembers_capacity'      =>  30,

    # hive priority for non-LOCAL health_check analysis:
        'hc_priority'               => -10,

    # connection parameters to various databases:

        # Uncomment and update the database locations

        # the production database itself (will be created)
        # it inherits most of the properties from HiveGeneric, we usually only need to redefine the host, but you may want to also redefine 'port'
        #'host' => 'compara1',

        # the master database for synchronization of various ids (use undef if you don't have a master database)
        #'master_db' => 'mysql://ensro@compara1:3306/sf5_ensembl_compara_master',
        'master_db' => undef,
        'ncbi_db'   => $self->o('master_db'),

        # NOTE: The databases referenced in the following arrays have to be hashes (not URLs)
        # Add the database entries for the current core databases and link 'curr_core_sources_locs' to them
        #'curr_core_sources_locs'    => [ $self->o('staging_loc1'), $self->o('staging_loc2') ],
        #'curr_core_registry'        => "registry.conf",
        'curr_core_registry'        => undef,
        'curr_file_sources_locs'    => [  ],    # It can be a list of JSON files defining an additionnal set of species

        # Add the database entries for the core databases of the previous release
        #'prev_core_sources_locs'   => [ $self->o('livemirror_loc') ],

        # Add the database location of the previous Compara release. Use "undef" if running the pipeline without reuse
        #'prev_rel_db' => 'mysql://ensro@compara3:3306/mm14_compara_homology_67'

        # How will the pipeline create clusters (families) ?
        # Possible values: 'blastp' (default), 'hmm', 'hybrid'
        #   blastp means that the pipeline will run a all-vs-all blastp comparison of the proteins and run hcluster to create clusters. This can take a *lot* of compute
        #   hmm means that the pipeline will run an HMM classification
        #   hybrid is like "hmm" except that the unclustered proteins go to a all-vs-all blastp + hcluster stage
        'clustering_mode'           => 'blastp',

        # How much the pipeline will try to reuse from "prev_rel_db"
        # Possible values: 'clusters' (default), 'blastp', 'members'
        #   clusters means that the members, the blastp hits and the clusters are copied over. In this case, the blastp hits are actually not copied over if "skip_blast_copy_if_possible" is set
        #   blastp means that only the members and the blastp hits are copied over
        #   members means that only the members are copied over
        'reuse_level'               => 'clusters',
        # If all the species can be reused, and if the reuse_level is "clusters", do we really want to copy all the peptide_align_feature tables ? They can take a lot of space and are not used in the pipeline
        'skip_blast_copy_if_possible'   => 1,

    };
}


=head2
# This section has to be filled in any derived class
sub resource_classes {
    my ($self) = @_;
    return {
        %{$self->SUPER::resource_classes},  # inherit 'default' from the parent class

         '250Mb_job'    => {'LSF' => '-C0 -M250   -R"select[mem>250]   rusage[mem=250]"' },
         '500Mb_job'    => {'LSF' => '-C0 -M500   -R"select[mem>500]   rusage[mem=500]"' },
         '1Gb_job'      => {'LSF' => '-C0 -M1000  -R"select[mem>1000]  rusage[mem=1000]"' },
         '2Gb_job'      => {'LSF' => '-C0 -M2000  -R"select[mem>2000]  rusage[mem=2000]"' },
         '4Gb_job'      => {'LSF' => '-C0 -M4000  -R"select[mem>4000]  rusage[mem=4000]"' },
         '8Gb_job'      => {'LSF' => '-C0 -M8000  -R"select[mem>8000]  rusage[mem=8000]"' },
         '16Gb_job'     => {'LSF' => '-C0 -M16000 -R"select[mem>16000] rusage[mem=16000]"' },
         '32Gb_job'     => {'LSF' => '-C0 -M32000 -R"select[mem>32000] rusage[mem=32000]"' },
         '64Gb_job'     => {'LSF' => '-C0 -M64000 -R"select[mem>64000] rusage[mem=64000]"' },

         'msa'          => {'LSF' => '-C0 -M2000  -R"select[mem>2000]  rusage[mem=2000]"' },
         'msa_himem'    => {'LSF' => '-C0 -M8000  -R"select[mem>8000]  rusage[mem=8000]"' },

         'urgent_hcluster'      => {'LSF' => '-C0 -M32000 -R"select[mem>32000] rusage[mem=32000]"' },
    };
}
=cut


sub pipeline_create_commands {
    my ($self) = @_;

    # There must be some species on which to compute trees
    die "There must be some species on which to compute trees"
        if ref $self->o('curr_core_sources_locs') and not scalar(@{$self->o('curr_core_sources_locs')})
        and ref $self->o('curr_file_sources_locs') and not scalar(@{$self->o('curr_file_sources_locs')})
        and not $self->o('curr_core_registry');

    # The master db must be defined to allow mapping stable_ids and checking species for reuse
    die "The master dabase must be defined with a mlss_id" if $self->o('master_db') and not $self->o('mlss_id');
    die "mlss_id can not be defined in the absence of a master dabase" if $self->o('mlss_id') and not $self->o('master_db');
    die "Mapping of stable_id is only possible with a master database" if $self->o('do_stable_id_mapping') and not $self->o('master_db');
    die "Species reuse is only possible with a master database" if $self->o('prev_rel_db') and not $self->o('master_db');
    die "Species reuse is only possible with some previous core databases" if $self->o('prev_rel_db') and ref $self->o('prev_core_sources_locs') and not scalar(@{$self->o('prev_core_sources_locs')});

    # Without a master database, we must provide other parameters
    die if not $self->o('master_db') and not $self->o('ncbi_db');

    my %reuse_modes = (clusters => 1, blastp => 1, members => 1);
    die "'reuse_level' must be set to one of: clusters, blastp, members" if not $self->o('reuse_level') or (not $reuse_modes{$self->o('reuse_level')} and not $self->o('reuse_level') =~ /^#:subst/);
    my %clustering_modes = (blastp => 1, hmm => 1, hybrid => 1);
    die "'clustering_mode' must be set to one of: blastp, hmm, hybrid" if not $self->o('clustering_mode') or (not $clustering_modes{$self->o('clustering_mode')} and not $self->o('clustering_mode') =~ /^#:subst/);

    return [
        @{$self->SUPER::pipeline_create_commands},  # here we inherit creation of database, hive tables and compara tables

        'mkdir -p '.$self->o('cluster_dir'),
        'mkdir -p '.$self->o('dump_dir'),
        'mkdir -p '.$self->o('fasta_dir'),
        'mkdir -p '.$self->o('hmmlib_dir'),

            # perform "lfs setstripe" only if lfs is runnable and the directory is on lustre:
        'which lfs && lfs getstripe '.$self->o('fasta_dir').' >/dev/null 2>/dev/null && lfs setstripe '.$self->o('fasta_dir').' -c -1 || echo "Striping is not available on this system" ',
    ];
}


sub pipeline_wide_parameters {  # these parameter values are visible to all analyses, can be overridden by parameters{} and input_id{}
    my ($self) = @_;
    return {
        %{$self->SUPER::pipeline_wide_parameters},          # here we inherit anything from the base class

        'master_db'     => $self->o('master_db'),
        'ncbi_db'       => $self->o('ncbi_db'),
        'reuse_db'      => $self->o('prev_rel_db'),

        'cluster_dir'   => $self->o('cluster_dir'),
        'fasta_dir'     => $self->o('fasta_dir'),
        'dump_dir'      => $self->o('dump_dir'),
        'hmmlib_dir'    => $self->o('hmmlib_dir'),

        'reuse_level'   => $self->o('reuse_level'),
        'clustering_mode'   => $self->o('clustering_mode'),
    };
}


sub core_pipeline_analyses {
    my ($self) = @_;

    my %hc_analysis_params = (
            -analysis_capacity  => $self->o('hc_capacity'),
            -priority           => $self->o('hc_priority'),
            -batch_size         => 20,
    );

    return [

# ---------------------------------------------[backbone]--------------------------------------------------------------------------------

        {   -logic_name => 'backbone_fire_db_prepare',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::Dummy',
            -input_ids  => [ {
                'output_file'   => '#dump_dir#/#filename#.sql.gz',
            } ],
            -flow_into  => {
                '1->A'  => [ 'copy_ncbi_tables_factory' ],
                'A->1'  => [ 'backbone_fire_genome_load' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'backbone_fire_genome_load',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::DatabaseDumper',
            -parameters => {
                'table_list'        => '',
                'filename'          => 'snapshot_1_before_genome_load',
            },
            -flow_into  => {
                '1->A'  => [ 'genome_reuse_factory' ],
                'A->1'  => [ 'test_should_blast_be_skipped' ],
            },
        },

        {   -logic_name => 'test_should_blast_be_skipped',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ConditionalDataFlow',
            -parameters    => {
                'skip_blast_copy_if_possible'   => $self->o('skip_blast_copy_if_possible'),
                'condition'     => '(#are_all_species_reused# and #skip_blast_copy_if_possible#) or ("#clustering_mode#" ne "blastp")',
            },
            -flow_into => {
                2 => [ 'backbone_fire_clustering' ],
                3 => [ 'backbone_fire_allvsallblast' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'backbone_fire_allvsallblast',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::DatabaseDumper',
            -parameters => {
                'table_list'    => '',
                'filename'      => 'snapshot_2_before_allvsallblast',
            },
            -flow_into  => {
                '1->A'  => [ 'blastdb_factory' ],
                'A->1'  => [ 'backbone_fire_clustering' ],
            },
        },

        {   -logic_name => 'backbone_fire_clustering',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::DatabaseDumper',
            -parameters => {
                'table_list'    => '',
                'filename'      => 'snapshot_3_before_clustering',
            },
            -flow_into  => {
                '1->A'  => [ 'test_whether_can_copy_clusters' ],
                'A->1'  => [ 'backbone_fire_tree_building' ],
            },
        },

        {   -logic_name => 'backbone_fire_tree_building',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::DatabaseDumper',
            -parameters => {
                'table_list'    => 'peptide_align_feature_%',
                'exclude_list'  => 1,
                'filename'      => 'snapshot_4_before_tree_building',
            },
            -flow_into  => {
                '1->A'  => [ 'cluster_factory' ],
                'A->1'  => [ 'backbone_fire_dnds' ],
            },
        },

        {   -logic_name => 'backbone_fire_dnds',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::DatabaseDumper',
            -parameters => {
                'table_list'    => 'peptide_align_feature_%',
                'exclude_list'  => 1,
                'filename'      => 'snapshot_5_before_dnds',
            },
            -flow_into  => {
                '1->A'  => [ 'group_genomes_under_taxa' ],
                'A->1'  => [ 'backbone_pipeline_finished' ],
            },
        },


        {   -logic_name => 'backbone_pipeline_finished',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::Dummy',
            -meadow_type    => 'LOCAL',
        },

# ---------------------------------------------[copy tables from master]-----------------------------------------------------------------

        {   -logic_name => 'copy_ncbi_tables_factory',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::JobFactory',
            -parameters => {
                'inputlist'    => [ 'ncbi_taxa_node', 'ncbi_taxa_name' ],
                'column_names' => [ 'table' ],
                'fan_branch_code' => 2,
            },
            -flow_into => {
                '2->A' => [ 'copy_ncbi_table'  ],
                'A->1' => [ 'test_can_use_master_db'],
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name    => 'copy_ncbi_table',
            -module        => 'Bio::EnsEMBL::Hive::RunnableDB::MySQLTransfer',
            -parameters    => {
                'src_db_conn'   => '#ncbi_db#',
                'mode'          => 'overwrite',
                'filter_cmd'    => 'sed "s/ENGINE=MyISAM/ENGINE=InnoDB/"',
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'test_can_use_master_db',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ConditionalDataFlow',
            -parameters    => {
                'condition'     => '$self->param_is_defined("master_db")',
            },
            -flow_into => {
                2 => [ 'populate_method_links_from_db' ],
                3 => [ 'populate_method_links_from_file' ],
            },
            -meadow_type    => 'LOCAL',
        },


        {   -logic_name    => 'populate_method_links_from_db',
            -module        => 'Bio::EnsEMBL::Hive::RunnableDB::MySQLTransfer',
            -parameters    => {
                'src_db_conn'   => '#master_db#',
                'mode'          => 'overwrite',
                'filter_cmd'    => 'sed "s/ENGINE=MyISAM/ENGINE=InnoDB/"',
                'table'         => 'method_link',
            },
            -analysis_capacity  => 1,
            -flow_into      => [ 'load_genomedb_factory' ],
            -meadow_type    => 'LOCAL',
        },

# ---------------------------------------------[load GenomeDB entries from master+cores]---------------------------------------------

        {   -logic_name => 'load_genomedb_factory',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ObjectFactory',
            -parameters => {
                'compara_db'            => '#master_db#',   # that's where genome_db_ids come from

                'call_list'             => [ 'compara_dba', 'get_MethodLinkSpeciesSetAdaptor', ['fetch_by_dbID', $self->o('mlss_id')], 'species_set_obj', 'genome_dbs'],
                'column_names2getters'  => { 'genome_db_id' => 'dbID', 'species_name' => 'name', 'assembly_name' => 'assembly', 'genebuild' => 'genebuild', 'locator' => 'locator', 'has_karyotype' => 'has_karyotype', 'is_high_coverage' => 'is_high_coverage' },

                'fan_branch_code'       => 2,
            },
            -flow_into => {
                '2->A' => [ 'load_genomedb' ],
                'A->1' => [ 'create_mlss_ss' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'load_genomedb',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::LoadOneGenomeDB',
            -parameters => {
                'registry_conf_file'  => $self->o('curr_core_registry'),
                'registry_dbs'  => $self->o('curr_core_sources_locs'),
                'db_version'    => $self->o('ensembl_release'),
                'registry_files'    => $self->o('curr_file_sources_locs'),
            },
            -flow_into  => [ 'check_reusability' ],
            -analysis_capacity => 1,
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name     => 'populate_method_links_from_file',
            -module         => 'Bio::EnsEMBL::Hive::RunnableDB::SystemCmd',
            -parameters     => {
                'method_link_dump_file' => $self->o('method_link_dump_file'),
                'command_line_db'   => $self->dbconn_2_mysql('pipeline_db', 1),
                'cmd'               => 'mysqlimport #command_line_db# #method_link_dump_file#',
            },
            -flow_into      => [ 'load_all_genomedbs' ],
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'load_all_genomedbs',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::LoadAllGenomeDBs',
            -parameters => {
                'registry_conf_file'  => $self->o('curr_core_registry'),
                'registry_dbs'  => $self->o('curr_core_sources_locs'),
                'db_version'    => $self->o('ensembl_release'),
                'registry_files'    => $self->o('curr_file_sources_locs'),
            },
            -analysis_capacity => 1,
            -meadow_type    => 'LOCAL',
            -flow_into => [ 'create_mlss_ss' ],
        },
# ---------------------------------------------[filter genome_db entries into reusable and non-reusable ones]------------------------

        {   -logic_name => 'check_reusability',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::CheckGenomedbReusability',
            -parameters => {
                'registry_dbs'      => $self->o('prev_core_sources_locs'),
                'do_not_reuse_list' => $self->o('do_not_reuse_list'),
            },
            -hive_capacity => 10,
            -rc_name => '500Mb_job',
            -flow_into => {
                2 => { ':////accu?reused_gdb_ids=[]' => { 'reused_gdb_ids' => '#genome_db_id#'} },
                3 => { ':////accu?nonreused_gdb_ids=[]' => { 'nonreused_gdb_ids' => '#genome_db_id#'} },
            },
        },

        {   -logic_name => 'create_mlss_ss',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::PrepareSpeciesSetsMLSS',
            -parameters => {
                'mlss_id'   => $self->o('mlss_id'),
            },
            -flow_into => [ 'make_treebest_species_tree', 'extra_sql_prepare' ],
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name    => 'extra_sql_prepare',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::SqlCmd',
            -parameters => {
                'sql' => [
                    # Counts the number of species
                    'INSERT INTO meta (meta_key,meta_value) SELECT "species_count", COUNT(*) FROM genome_db',
                    # Whether all the species are reused
                    'INSERT INTO meta (meta_key,meta_value) SELECT "are_all_species_reused", IF(meta_value = "-1", 1, 0) FROM meta WHERE meta_key = "nonreuse_ss_csv"',
                ],
            },
            -meadow_type    => 'LOCAL',
        },

# ---------------------------------------------[load species tree]-------------------------------------------------------------------

        {   -logic_name    => 'make_treebest_species_tree',
            -module        => 'Bio::EnsEMBL::Compara::RunnableDB::MakeSpeciesTree',
            -parameters    => {
                               'species_tree_input_file' => $self->o('species_tree_input_file'),   # empty by default, but if nonempty this file will be used instead of tree generation from genome_db
                               'do_transactions' => 1,
            },
            -flow_into     => {
                2 => [ 'hc_species_tree' ],
            }
        },

        {   -logic_name         => 'hc_species_tree',
            -module             => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::SqlHealthChecks',
            -parameters         => {
                mode            => 'species_tree',
                binary          => 0,
            },
            -flow_into  => [ 'has_user_provided_binary_species_tree' ],
            %hc_analysis_params,
        },

        {   -logic_name => 'has_user_provided_binary_species_tree',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ConditionalDataFlow',
            -parameters    => {
                'condition'     => $self->o('binary_species_tree_input_file') ? 1 : 0,
            },
            -flow_into => {
                2 => [ 'load_binary_species_tree' ],
                3 => [ 'make_binary_species_tree' ],
            },
            -meadow_type    => 'LOCAL',
        },

         {   -logic_name    => 'load_binary_species_tree',
            -module        => 'Bio::EnsEMBL::Compara::RunnableDB::MakeSpeciesTree',
            -parameters    => {
                               'label' => 'binary',
                               'species_tree_input_file' => $self->o('binary_species_tree_input_file'),
                               'do_transactions' => 1,
            },
            -flow_into     => {
                2 => [ 'hc_binary_species_tree' ],
            }
        },

        {   -logic_name    => 'make_binary_species_tree',
            -module        => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::CAFESpeciesTree',
            -parameters    => {
                'new_label'     => 'binary',
                'tree_fmt'      => '%{-x"*"}:%{d}',
                'label'         => 'default',
            },
            -flow_into     => {
                2 => [ 'hc_binary_species_tree' ],
            }
        },

        {   -logic_name         => 'hc_binary_species_tree',
            -module             => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::SqlHealthChecks',
            -parameters         => {
                mode            => 'species_tree',
                binary          => 1,
            },
            %hc_analysis_params,
        },


# ---------------------------------------------[reuse members]-----------------------------------------------------------------------

        {   -logic_name => 'genome_reuse_factory',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::JobFactory',
            -parameters => {
                'inputquery'        => 'SELECT genome_db_id, name FROM species_set JOIN genome_db USING (genome_db_id) WHERE species_set_id = #reuse_ss_id#',
                'fan_branch_code'   => 2,
            },
            -flow_into => {
                '2->A' => [ 'sequence_table_reuse' ],
                'A->1' => [ 'load_fresh_members_factory' ],
            },
            -meadow_type    => 'LOCAL',
        },


        {   -logic_name => 'sequence_table_reuse',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::JobFactory',
            -parameters => {
                            'db_conn'    => '#reuse_db#',
                            'inputquery' => 'SELECT s.* FROM sequence s JOIN seq_member USING (sequence_id) WHERE sequence_id<='.$self->o('protein_members_range').' AND genome_db_id = #genome_db_id#',
                            'fan_branch_code' => 2,
            },
            -hive_capacity => $self->o('reuse_capacity'),
            -rc_name => '500Mb_job',
            -flow_into => {
                2 => [ ':////sequence' ],
                1 => [ 'dnafrag_table_reuse' ],
            },
        },

        {   -logic_name => 'dnafrag_table_reuse',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::MySQLTransfer',
            -parameters => {
                'src_db_conn'   => '#reuse_db#',
                'table'         => 'dnafrag',
                'where'         => 'genome_db_id = #genome_db_id#',
                'mode'          => 'topup',
            },
            -hive_capacity => $self->o('reuse_capacity'),
            -flow_into => {
                1 => [ 'seq_member_table_reuse' ],
            },
        },

        {   -logic_name => 'seq_member_table_reuse',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::MySQLTransfer',
            -parameters => {
                'src_db_conn'   => '#reuse_db#',
                'table'         => 'seq_member',
                'where'         => 'seq_member_id<='.$self->o('protein_members_range').' AND genome_db_id = #genome_db_id#',
                'mode'          => 'topup',
            },
            -hive_capacity => $self->o('reuse_capacity'),
            -flow_into => {
                1 => [ 'gene_member_table_reuse' ],
            },
        },

        {   -logic_name => 'gene_member_table_reuse',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::MySQLTransfer',
            -parameters => {
                'src_db_conn'   => '#reuse_db#',
                'table'         => 'gene_member',
                'where'         => 'gene_member_id<='.$self->o('protein_members_range').' AND genome_db_id = #genome_db_id#',
                'mode'          => 'topup',
            },
            -hive_capacity => $self->o('reuse_capacity'),
            -flow_into => {
                1 => [ 'other_sequence_table_reuse' ],
            },
        },

        {   -logic_name => 'other_sequence_table_reuse',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::JobFactory',
            -parameters => {
                            'db_conn'    => '#reuse_db#',
                            'inputquery' => 'SELECT s.seq_member_id, s.seq_type, s.length, s.sequence FROM other_member_sequence s JOIN seq_member USING (seq_member_id) WHERE genome_db_id = #genome_db_id# AND seq_type IN ("cds", "exon_bounded") AND seq_member_id <= '.$self->o('protein_members_range'),
                            'fan_branch_code' => 2,
            },
            -hive_capacity => $self->o('reuse_capacity'),
            -rc_name => '1Gb_job',
            -flow_into => {
                2 => [ ':////other_member_sequence' ],
                1 => [ 'hc_members_per_genome' ],
            },
        },

        {   -logic_name         => 'hc_members_per_genome',
            -module             => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::SqlHealthChecks',
            -parameters         => {
                mode            => 'members_per_genome',
                allow_ambiguity_codes => $self->o('allow_ambiguity_codes'),
            },
            %hc_analysis_params,
        },


# ---------------------------------------------[load the rest of members]------------------------------------------------------------

        {   -logic_name => 'load_fresh_members_factory',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::JobFactory',
            -parameters => {
                'inputquery'        => 'SELECT genome_db_id, name, locator FROM species_set JOIN genome_db USING (genome_db_id) WHERE species_set_id = #nonreuse_ss_id#',
                'fan_branch_code'   => 2,
            },
            -flow_into => {
                '2->A' => [ 'test_is_genome_in_core_db' ],
                'A->1' => [ 'hc_members_globally' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'test_is_genome_in_core_db',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ConditionalDataFlow',
            -parameters    => {
                'condition'     => '"#locator#" =~ /^Bio::EnsEMBL::DBSQL::DBAdaptor/',
            },
            -flow_into => {
                2 => [ 'test_is_there_master_db' ],
                3 => [ 'load_fresh_members_from_file' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'test_is_there_master_db',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ConditionalDataFlow',
            -parameters    => {
                'condition'     => '$self->param_is_defined("master_db")',
            },
            -flow_into => {
                2 => [ 'copy_dnafrags_from_master' ],
                3 => { 'load_fresh_members_from_db' => { 'genome_db_id' => '#genome_db_id#', 'store_missing_dnafrags' => 1} },
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'copy_dnafrags_from_master',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::MySQLTransfer',
            -parameters => {
                'src_db_conn'   => '#master_db#',
                'table'         => 'dnafrag',
                'where'         => 'genome_db_id = #genome_db_id#',
                'mode'          => 'topup',
            },
            -hive_capacity => $self->o('reuse_capacity'),
            -flow_into => [ 'load_fresh_members_from_db' ],
        },

        {   -logic_name => 'load_fresh_members_from_db',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::LoadMembers',
            -parameters => {
                'store_related_pep_sequences' => 1,
                'allow_pyrrolysine'             => $self->o('allow_pyrrolysine'),
                'find_canonical_translations_for_polymorphic_pseudogene' => 1,
                'store_missing_dnafrags'        => 0,
            },
            -hive_capacity => $self->o('loadmembers_capacity'),
            -rc_name => '2Gb_job',
            -flow_into => [ 'hc_members_per_genome' ],
        },

        {   -logic_name => 'load_fresh_members_from_file',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::LoadMembersFromFiles',
            -parameters => {
                -need_cds_seq   => 1,
            },
            -hive_capacity => $self->o('loadmembers_capacity'),
            -rc_name => '2Gb_job',
            -flow_into => [ 'hc_members_per_genome' ],
        },

        {   -logic_name         => 'hc_members_globally',
            -module             => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::SqlHealthChecks',
            -parameters         => {
                mode            => 'members_globally',
            },
            %hc_analysis_params,
        },

# ---------------------------------------------[create and populate blast analyses]--------------------------------------------------

        {   -logic_name => 'reusedspecies_factory',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::JobFactory',
            -parameters => {
                '_force_blast_run'   => '#expr(#reuse_level# eq "members" ? 1 : 0)expr#',
                'inputquery'        => 'SELECT genome_db_id, name FROM species_set JOIN genome_db USING (genome_db_id) WHERE species_set_id = #reuse_ss_id# AND NOT #_force_blast_run#',
                'fan_branch_code'   => 2,
            },
            -flow_into => {
                2 => [ 'paf_table_reuse' ],
                1 => [ 'nonreusedspecies_factory' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'nonreusedspecies_factory',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::JobFactory',
            -parameters => {
                '_force_blast_run'   => '#expr(#reuse_level# eq "members" ? 1 : 0)expr#',
                'inputquery'        => 'SELECT genome_db_id, name FROM species_set JOIN genome_db USING (genome_db_id) WHERE species_set_id = #nonreuse_ss_id# OR #_force_blast_run#',
                'fan_branch_code'   => 2,
            },
            -flow_into => {
                2 => [ 'paf_create_empty_table' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'paf_table_reuse',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::MySQLTransfer',
            -parameters => {
                'src_db_conn'   => '#reuse_db#',
                'table'         => 'peptide_align_feature_#genome_db_id#',
                'filter_cmd'    => 'sed "s/ENGINE=MyISAM/ENGINE=InnoDB/"',
                'where'         => 'hgenome_db_id IN (#reuse_ss_csv#)',
            },
            -flow_into  => [ 'members_against_nonreusedspecies_factory' ],
            -hive_capacity => $self->o('reuse_capacity'),
        },

        {   -logic_name => 'paf_create_empty_table',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::SqlCmd',
            -parameters => {
                'sql' => [  'CREATE TABLE IF NOT EXISTS peptide_align_feature_#genome_db_id# LIKE peptide_align_feature',
                            'ALTER TABLE peptide_align_feature_#genome_db_id# DISABLE KEYS, AUTO_INCREMENT=#genome_db_id#00000000',
                ],
            },
            -flow_into  => [ 'members_against_allspecies_factory' ],
            -analysis_capacity => 1,
            -meadow_type    => 'LOCAL',
        },

#--------------------------------------------------------[load the HMM profiles]----------------------------------------------------
        {   -logic_name => 'panther_databases_factory',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::JobFactory',
            -parameters => {
                'inputlist'    => $self->o('panther_like_databases'),
                'column_names' => [ 'cm_file_or_directory', 'type', 'include_subfamilies' ],
                'fan_branch_code' => 2,
            },
            -flow_into => {
                '2->A' => [ 'load_panther_database_models'  ],
                'A->1' => [ 'multihmm_files_factory' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'multihmm_files_factory',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::JobFactory',
            -parameters => {
                'inputlist'    => $self->o('multihmm_files'),
                'column_names' => [ 'cm_file_or_directory', 'type' ],
                'fan_branch_code' => 2,
            },
            -flow_into => {
                '2->A' => [ 'load_multihmm_models'  ],
                'A->1' => [ 'dump_models' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {
            -logic_name => 'load_panther_database_models',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ComparaHMM::PantherLoadModels',
            -parameters => {
                'pantherScore_path'    => $self->o('pantherScore_path'),
            },
        },

        {
            -logic_name => 'load_multihmm_models',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ComparaHMM::MultiHMMLoadModels',
            -parameters => {
            },
         },

            {
             -logic_name => 'dump_models',
             -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ComparaHMM::DumpModels',
             -parameters => {
                             'hmm_library_basedir' => '#hmmlib_dir#',
                             'blast_bin_dir'       => $self->o('blast_bin_dir'),  ## For creating the blastdb (formatdb or mkblastdb)
                             'pantherScore_path'    => $self->o('pantherScore_path'),
                            },
             -flow_into  => [ 'load_InterproAnnotation' ],
            },

#----------------------------------------------[classify canonical members based on HMM searches]-----------------------------------
        {
            -logic_name     => 'load_InterproAnnotation',
            -module         => 'Bio::EnsEMBL::Hive::RunnableDB::SqlCmd',
            -parameters     => {
                'panther_annotation_file'   => $self->o('panther_annotation_file'),
                'sql'                       => "LOAD DATA LOCAL INFILE '#panther_annotation_file#' INTO TABLE panther_annot
                                                FIELDS TERMINATED BY '\\t' LINES TERMINATED BY '\\n'
                                                (upi, ensembl_id, ensembl_div, panther_family_id, start, end, score, evalue)",
            },
            -flow_into      => [ 'HMMer_classifyCurated' ],
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'HMMer_classify_factory',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ObjectFactory',
            -parameters => {
                'call_list'             => [ 'compara_dba', 'get_GenomeDBAdaptor', 'fetch_all'],
                'column_names2getters'  => { 'genome_db_id' => 'dbID' },

                'fan_branch_code'       => 2,
            },
            -flow_into  => {
                '2->A'  => [ 'HMMer_classifyPantherScore' ],
                'A->1'  => [ 'HMM_clusterize' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {
            -logic_name     => 'HMMer_classifyCurated',
            -module         => 'Bio::EnsEMBL::Hive::RunnableDB::SqlCmd',
            -parameters     => {
                'sql'   => 'INSERT INTO hmm_annot SELECT seq_member_id, model_id, NULL FROM hmm_curated_annot hca JOIN seq_member sm ON sm.stable_id = hca.seq_member_stable_id',
            },
            -flow_into      => [ 'HMMer_classifyInterpro' ],
            -meadow_type    => 'LOCAL',
        },

        {
            -logic_name     => 'HMMer_classifyInterpro',
            -module         => 'Bio::EnsEMBL::Hive::RunnableDB::SqlCmd',
            -parameters     => {
                'sql'   => 'INSERT IGNORE INTO hmm_annot SELECT seq_member_id, panther_family_id, evalue FROM panther_annot pa JOIN seq_member sm ON sm.stable_id = pa.ensembl_id',
            },
            -flow_into      => [ 'HMMer_classify_factory' ],
            -meadow_type    => 'LOCAL',
        },

            {
             -logic_name => 'HMMer_classifyPantherScore',
             -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ComparaHMM::HMMClassifyPantherScore',
             -parameters => {
                             'blast_bin_dir'       => $self->o('blast_bin_dir'),
                             'pantherScore_path'   => $self->o('pantherScore_path'),
                             'hmmer_path'          => $self->o('hmmer2_home'),
                             'hmm_library_basedir' => '#hmmlib_dir#',
                            },
             -hive_capacity => $self->o('HMMer_classify_capacity'),
             -rc_name => '4Gb_job',
            },

            {
             -logic_name => 'HMM_clusterize',
             -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ComparaHMM::HMMClusterize',
             -rc_name => '8Gb_job',
            },




# -------------------------------------------------[BuildHMMprofiles pipeline]-------------------------------------------------------

        {   -logic_name => 'dump_unannotated_members',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ComparaHMM::DumpUnannotatedMembersIntoFasta',
            -parameters => {
                'fasta_file'    => '#fasta_dir#/unannotated.fasta',
            },
            -rc_name       => '250Mb_job',
            -hive_capacity => $self->o('reuse_capacity'),
            -flow_into => [ 'make_blastdb_unannotated' ],
        },

        {   -logic_name => 'make_blastdb_unannotated',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::SystemCmd',
            -parameters => {
                'blast_bin_dir' => $self->o('blast_bin_dir'),
                'cmd' => '#blast_bin_dir#/makeblastdb -dbtype prot -parse_seqids -logfile #fasta_name#.blastdb_log -in #fasta_name#',
            },
            -flow_into  => [ 'unannotated_all_vs_all_factory' ],
        },

        {   -logic_name => 'unannotated_all_vs_all_factory',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ComparaHMM::FactoryUnannotatedMembers',
            -rc_name       => '250Mb_job',
            -hive_capacity => $self->o('blast_factory_capacity'),
            -flow_into => {
                '2->A' => [ 'blastp_unannotated' ],
                'A->1' => [ 'hcluster_dump_input_all_pafs' ]
            },
        },

        {   -logic_name         => 'blastp_unannotated',
            -module             => 'Bio::EnsEMBL::Compara::RunnableDB::ComparaHMM::BlastpUnannotated',
            -parameters         => {
                'blast_db'                  => '#fasta_dir#/unannotated.fasta',
                'blast_params'              => $self->o('blast_params'),
                'blast_bin_dir'             => $self->o('blast_bin_dir'),
                'evalue_limit'              => 1e-10,
            },
            -rc_name       => '250Mb_job',
            -hive_capacity => $self->o('blastpu_capacity'),
        },

        {   -logic_name => 'hcluster_dump_input_all_pafs',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::HclusterPrepareSingleTable',
            -parameters => {
                'outgroups'     => $self->o('outgroups'),
            },
            -hive_capacity => $self->o('reuse_capacity'),
            -flow_into  => [ 'hcluster_run' ],
        },




# ---------------------------------------------[create and populate blast analyses]--------------------------------------------------

        {   -logic_name => 'blastdb_factory',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ObjectFactory',
            -parameters => {
                'call_list'             => [ 'compara_dba', 'get_GenomeDBAdaptor', 'fetch_all'],
                'column_names2getters'  => { 'genome_db_id' => 'dbID' },

                'fan_branch_code'       => 2,
            },
            -flow_into  => {
                '2->A'  => [ 'dump_canonical_members' ],
                'A->1'  => [ 'reusedspecies_factory' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'dump_canonical_members',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::DumpMembersIntoFasta',
            -parameters => {
                # Gets fasta_dir from pipeline_wide_parameters
                'only_canonical'            => 1,
            },
            -rc_name       => '250Mb_job',
            -hive_capacity => $self->o('reuse_capacity'),
            -flow_into => [ 'make_blastdb' ],
        },

        {   -logic_name => 'make_blastdb',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::SystemCmd',
            -parameters => {
                'blast_bin_dir' => $self->o('blast_bin_dir'),
                'cmd' => '#blast_bin_dir#/makeblastdb -dbtype prot -parse_seqids -logfile #fasta_name#.blastdb_log -in #fasta_name#',
            },
        },

        {   -logic_name => 'members_against_allspecies_factory',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::BlastFactory',
            -rc_name       => '250Mb_job',
            -hive_capacity => $self->o('blast_factory_capacity'),
            -flow_into => {
                '2->A' => [ 'blastp' ],
                'A->1' => [ 'hc_pafs' ],
            },
        },

        {   -logic_name => 'members_against_nonreusedspecies_factory',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::BlastFactory',
            -parameters => {
                'species_set_id'    => '#nonreuse_ss_id#',
            },
            -rc_name       => '250Mb_job',
            -hive_capacity => $self->o('blast_factory_capacity'),
            -flow_into => {
                '2->A' => [ 'blastp' ],
                'A->1' => [ 'hc_pafs' ],
            },
        },

        {   -logic_name         => 'blastp',
            -module             => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::BlastpWithReuse',
            -parameters         => {
                'blast_params'              => $self->o('blast_params'),
                'blast_bin_dir'             => $self->o('blast_bin_dir'),
                'evalue_limit'              => 1e-10,
                'allow_same_species_hits'   => 1,
            },
            -batch_size    => 10,
            -rc_name       => '250Mb_job',
            -hive_capacity => $self->o('blastp_capacity'),
        },

        {   -logic_name         => 'hc_pafs',
            -module             => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::SqlHealthChecks',
            -parameters         => {
                mode            => 'peptide_align_features',
            },
            %hc_analysis_params,
        },

# ---------------------------------------------[clustering step]---------------------------------------------------------------------

        {   -logic_name => 'test_hmm_clustering',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ConditionalDataFlow',
            -parameters    => {
                'condition'     => '"#clustering_mode#" ne "blastp"',
            },
            -flow_into => {
                2 => 'test_hybrid_clustering',
                3 => 'hcluster_dump_factory',
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'test_hybrid_clustering',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ConditionalDataFlow',
            -parameters    => {
                'condition'     => '"#clustering_mode#" eq "hybrid"',
            },
            -flow_into => {
                '2->A' => 'panther_databases_factory',
                'A->2' => 'dump_unannotated_members',
                3 => 'panther_databases_factory',
            },
            -meadow_type    => 'LOCAL',
        },


        {   -logic_name => 'test_whether_can_copy_clusters',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ConditionalDataFlow',
            -parameters    => {
                'condition'     => '#are_all_species_reused# and ("#reuse_level#" eq "clusters")',
            },
            -flow_into => {
                '2->A' => [ 'copy_clusters' ],
                '3->A' => [ 'test_hmm_clustering' ],
                'A->1' => [ 'hc_clusters' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'hcluster_dump_factory',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ObjectFactory',
            -parameters => {
                'call_list'             => [ 'compara_dba', 'get_GenomeDBAdaptor', 'fetch_all'],
                'column_names2getters'  => { 'genome_db_id' => 'dbID' },

                'fan_branch_code'       => 2,
            },
            -flow_into  => {
                '2->A' => [ 'hcluster_dump_input_per_genome' ],
                'A->1' => [ 'hcluster_merge_factory' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'hcluster_dump_input_per_genome',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::HclusterPrepare',
            -parameters => {
                'outgroups'     => $self->o('outgroups'),
            },
            -hive_capacity => $self->o('reuse_capacity'),
        },

        {   -logic_name    => 'hcluster_merge_factory',
            -module         => 'Bio::EnsEMBL::Hive::RunnableDB::Dummy',
            -flow_into => {
                '1->A' => {
                    'hcluster_merge_inputs' => [{'ext' => 'txt'}, {'ext' => 'cat'}],
                },
                'A->1' => [ 'hcluster_run' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name    => 'hcluster_merge_inputs',
            -module        => 'Bio::EnsEMBL::Hive::RunnableDB::SystemCmd',
            -parameters    => {
                'cmd'           => 'cat #cluster_dir#/*.hcluster.#ext# > #cluster_dir#/hcluster.#ext#',
            },
        },

        {   -logic_name    => 'hcluster_run',
            -module        => 'Bio::EnsEMBL::Hive::RunnableDB::SystemCmd',
            -parameters    => {
                'clustering_max_gene_halfcount' => $self->o('clustering_max_gene_halfcount'),
                'hcluster_exe'                  => $self->o('hcluster_exe'),
                'cmd'                           => '#hcluster_exe# -m #clustering_max_gene_halfcount# -w 0 -s 0.34 -O -C #cluster_dir#/hcluster.cat -o #cluster_dir#/hcluster.out #cluster_dir#/hcluster.txt',
            },
            -flow_into => {
                1 => [ 'hcluster_parse_output' ],
            },
            -rc_name => 'urgent_hcluster',
        },

        {   -logic_name => 'hcluster_parse_output',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::HclusterParseOutput',
            -parameters => {
                'division'                  => $self->o('division'),
            },
            -rc_name => '250Mb_job',
        },

        {   -logic_name => 'copy_clusters',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::CopyClusters',
            -parameters => {
                'tags_to_copy'              => [ 'division' ],
            },
            -rc_name => '500Mb_job',
        },


        {   -logic_name         => 'hc_clusters',
            -module             => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::SqlHealthChecks',
            -parameters         => {
                mode            => 'global_tree_set',
            },
            -flow_into          => [ 'create_additional_clustersets' ],
            %hc_analysis_params,
        },

        {   -logic_name         => 'create_additional_clustersets',
            -module             => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::CreateClustersets',
            -parameters         => {
                member_type     => 'protein',
                'additional_clustersets'    => [qw(treebest phyml-aa phyml-nt nj-dn nj-ds nj-mm raxml)],
            },
            -flow_into          => [ 'run_qc_tests' ],
        },


# ---------------------------------------------[Pluggable QC step]----------------------------------------------------------

        {   -logic_name => 'run_qc_tests',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ObjectFactory',
            -parameters => {
                'call_list'             => [ 'compara_dba', 'get_GenomeDBAdaptor', 'fetch_all'],
                'column_names2getters'  => { 'genome_db_id' => 'dbID' },
                'fan_branch_code'       => 2,
            },
            -flow_into => {
                '2->A' => [ 'per_genome_qc' ],
                '1->A' => [ 'overall_qc' ],
                'A->1' => [ 'clusterset_backup' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'overall_qc',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::OverallGroupsetQC',
            -hive_capacity  => $self->o('qc_capacity'),
            -failed_job_tolerance => 0,
            -rc_name    => '2Gb_job',
        },

        {   -logic_name => 'per_genome_qc',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::PerGenomeGroupsetQC',
            -hive_capacity => $self->o('qc_capacity'),
            -failed_job_tolerance => 0,
        },

        {   -logic_name    => 'clusterset_backup',
            -module        => 'Bio::EnsEMBL::Hive::RunnableDB::SqlCmd',
            -parameters    => {
                'sql'         => 'INSERT INTO gene_tree_backup (seq_member_id, root_id) SELECT seq_member_id, root_id FROM gene_tree_node WHERE seq_member_id IS NOT NULL',
            },
            -analysis_capacity => 1,
            -meadow_type    => 'LOCAL',
        },


# ---------------------------------------------[main tree fan]-------------------------------------------------------------

        {   -logic_name => 'cluster_factory',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::JobFactory',
            -parameters => {
                'inputquery'        => 'SELECT root_id AS gene_tree_id FROM gene_tree_root WHERE tree_type = "tree"',
                'fan_branch_code'   => 2,
            },
            -flow_into  => {
                 '2->A' => [ 'alignment_entry_point' ],
                 'A->1' => [ 'hc_global_tree_set' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'alignment_entry_point',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::Dummy',
            -flow_into  => {
                 '1->A' => [ 'test_large_clusters_go_to_mafft' ],
                 'A->1' => [ 'hc_alignment' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'test_large_clusters_go_to_mafft',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ConditionalDataFlow',
            -parameters => {
                'condition'             => '$self->compara_dba->get_GeneTreeAdaptor->fetch_by_dbID(#gene_tree_id#)->get_value_for_tag("gene_count") > #mafft_gene_count#',
                'mafft_gene_count'      => $self->o('mafft_gene_count'),
            },
            -flow_into  => {
                2 => [ 'mafft' ],
                3 => [ 'test_previous_runtime' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'test_previous_runtime',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ConditionalDataFlow',
            -parameters => {
                'condition'             => '$self->compara_dba->get_GeneTreeAdaptor->fetch_by_dbID(#gene_tree_id#)->get_value_for_tag("reuse_aln_runtime", 0)/1000 > #mafft_runtime#',
                'mafft_runtime'         => $self->o('mafft_runtime'),
            },
            -flow_into  => {
                2 => [ 'mafft' ],
                3 => [ 'mcoffee' ],
            },
            -meadow_type    => 'LOCAL',
        },


        {   -logic_name => 'test_very_large_clusters_go_to_qtb',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ConditionalDataFlow',
            -parameters => {
                'condition'             => '$self->compara_dba->get_GeneTreeAdaptor->fetch_by_dbID(#gene_tree_id#)->get_value_for_tag("gene_count") > #treebreak_gene_count#',
                'treebreak_gene_count'  => $self->o('treebreak_gene_count'),
            },
            -flow_into  => {
                2  => [ 'quick_tree_break' ],
                3  => [ 'tree_entry_point', 'build_HMM_aa', 'build_HMM_cds' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name         => 'hc_global_tree_set',
            -module             => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::SqlHealthChecks',
            -parameters         => {
                mode            => 'global_tree_set',
            },
            -flow_into  => [
                $self->o('do_stable_id_mapping') ? 'stable_id_mapping' : (),
                $self->o('do_treefam_xref') ? 'treefam_xref_idmap' : (),
            ],
            %hc_analysis_params,
        },


# ---------------------------------------------[Pluggable MSA steps]----------------------------------------------------------

        {   -logic_name => 'mcoffee',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::MCoffee',
            -parameters => {
                'method'                => 'cmcoffee',
                'mcoffee_home'          => $self->o('mcoffee_home'),
                'mafft_home'            => $self->o('mafft_home'),
            },
            -hive_capacity        => $self->o('mcoffee_capacity'),
            -rc_name => 'msa',
            -flow_into => {
               -1 => [ 'mcoffee_himem' ],  # MEMLIMIT
               -2 => [ 'mafft' ],
            },
        },

        {   -logic_name => 'mafft',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::Mafft',
            -parameters => {
                'mafft_home'                 => $self->o('mafft_home'),
            },
            -hive_capacity        => $self->o('mcoffee_capacity'),
            -rc_name => 'msa',
            -flow_into => {
               -1 => [ 'mafft_himem' ],  # MEMLIMIT
            },
        },

        {   -logic_name => 'mcoffee_himem',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::MCoffee',
            -parameters => {
                'method'                => 'cmcoffee',
                'mcoffee_home'          => $self->o('mcoffee_home'),
                'mafft_home'            => $self->o('mafft_home'),
                'escape_branch'         => -2,
            },
            -hive_capacity        => $self->o('mcoffee_capacity'),
            -rc_name => 'msa_himem',
            -flow_into => {
               -1 => [ 'mafft_himem' ],
               -2 => [ 'mafft_himem' ],
            },
        },

        {   -logic_name => 'mafft_himem',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::Mafft',
            -parameters => {
                'mafft_home'                 => $self->o('mafft_home'),
            },
            -hive_capacity        => $self->o('mcoffee_capacity'),
            -rc_name => 'msa_himem',
        },

        {   -logic_name         => 'hc_alignment',
            -module             => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::SqlHealthChecks',
            -parameters         => {
                mode            => 'alignment',
            },
            -flow_into => [ 'test_very_large_clusters_go_to_qtb' ],
            %hc_analysis_params,
        },


# ---------------------------------------------[main tree creation loop]-------------------------------------------------------------

        {   -logic_name     => 'split_genes',
            -module         => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::FindContiguousSplitGenes',
            -hive_capacity  => $self->o('split_genes_capacity'),
            -rc_name        => '500Mb_job',
            -batch_size     => 20,
            -flow_into      => [ $self->o('use_raxml') ? 'trimal' : 'treebest' ],
        },

        {   -logic_name => 'tree_entry_point',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::Dummy',
            -meadow_type    => 'LOCAL',
            -flow_into  => {
                '1->A'   => [ 'split_genes' ],
                'A->1'   => [ 'hc_alignment_post_tree' ],
            },
        },

        {   -logic_name     => 'trimal',
            -module         => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::TrimAl',
            -parameters => {
                'trimal_exe'    => $self->o('trimal_exe'),
            },
            -hive_capacity  => $self->o('trimal_capacity'),
            -rc_name        => '500Mb_job',
            -batch_size     => 5,
            -flow_into      => [ 'raxml' ],
        },

        {   -logic_name => 'treebest',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::NJTREE_PHYML',
            -parameters => {
                'cdna'                      => 1,
                'bootstrap'                 => 1,
                'store_intermediate_trees'  => 1,
                'store_filtered_align'      => 1,
                'treebest_exe'              => $self->o('treebest_exe'),
                'output_clusterset_id'      => $self->o('use_notung') ? 'treebest' : 'notung',
            },
            -hive_capacity        => $self->o('treebest_capacity'),
            -rc_name => '4Gb_job',
            -flow_into => {
                2 => [ 'hc_tree_structure' ],
                $self->o('use_notung') ? (1 => [ 'notung' ]) : (),
            }
        },

        {   -logic_name => 'raxml',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::RAxML',
            -parameters => {
                #'cdna'                      => 1,
                'raxml_exe'              => $self->o('raxml_exe'),
                'treebest_exe'              => $self->o('treebest_exe'),
                'output_clusterset_id'      => $self->o('use_notung') ? 'raxml' : 'notung',
            },
            -hive_capacity        => $self->o('raxml_capacity'),
            -rc_name    => '8Gb_job',
            -flow_into  => {
                2 => { 'treebest' => { 'output_clusterset_id' => 'raxml', 'gene_tree_id' => '#gene_tree_id#' } },
                $self->o('use_notung') ? (1 => [ 'notung' ]) : (),
            }
        },

        {   -logic_name => 'notung',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::Notung',
            -parameters => {
                'notung_jar'                => $self->o('notung_jar'),
                'treebest_exe'              => $self->o('treebest_exe'),
                'label'                     => 'binary',
                'input_clusterset_id'       => $self->o('use_raxml') ? 'raxml' : 'treebest',
            },
            -hive_capacity        => $self->o('treebest_capacity'),
            -rc_name => '2Gb_job',
        },

        {   -logic_name         => 'hc_alignment_post_tree',
            -module             => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::SqlHealthChecks',
            -parameters         => {
                mode            => 'alignment',
            },
            -flow_into          => {
                '1->A' => [ 'hc_tree_structure' ],
                'A->1' => [ 'homology_entry_point' ],
            },
            %hc_analysis_params,
        },

        {   -logic_name         => 'hc_tree_structure',
            -module             => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::SqlHealthChecks',
            -parameters         => {
                mode            => 'tree_structure',
            },
            %hc_analysis_params,
        },

        {   -logic_name => 'homology_entry_point',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::Dummy',
            -flow_into  => [ 'ortho_tree', 'ktreedist', 'other_tree_factory' ],
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'other_tree_factory',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::JobFactory',
            -parameters => {
                'inputquery'        => 'SELECT root_id AS gene_tree_id FROM gene_tree_root WHERE ref_root_id = #gene_tree_id#',
                'fan_branch_code'   => 2,
            },
            -flow_into  => {
                 2 => [ 'ortho_tree_annot' ],
            },
            -meadow_type    => 'LOCAL',
        },


        {   -logic_name => 'ortho_tree',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::OrthoTree',
            -parameters => {
                'tag_split_genes'   => 1,
            },
            -hive_capacity      => $self->o('ortho_tree_capacity'),
            -rc_name => '250Mb_job',
            -flow_into  => [ 'hc_tree_attributes', 'hc_tree_homologies' ],
        },

        {   -logic_name         => 'hc_tree_attributes',
            -module             => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::SqlHealthChecks',
            -parameters         => {
                mode            => 'tree_attributes',
            },
            %hc_analysis_params,
        },

        {   -logic_name         => 'hc_tree_homologies',
            -module             => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::SqlHealthChecks',
            -parameters         => {
                mode            => 'tree_homologies',
            },
            %hc_analysis_params,
        },

        {   -logic_name    => 'ktreedist',
            -module        => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::Ktreedist',
            -parameters    => {
                               'treebest_exe'  => $self->o('treebest_exe'),
                               'ktreedist_exe' => $self->o('ktreedist_exe'),
                              },
            -hive_capacity => $self->o('ktreedist_capacity'),
            -batch_size => 5,
            -rc_name       => '2Gb_job',
        },

        {   -logic_name => 'ortho_tree_annot',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::OrthoTree',
            -parameters => {
                'tag_split_genes'   => 1,
                'store_homologies'  => 0,
            },
            -hive_capacity        => $self->o('ortho_tree_annot_capacity'),
            -rc_name => '250Mb_job',
            -batch_size => 20,
            -flow_into  => [ 'hc_tree_attributes' ],
        },

        {   -logic_name => 'build_HMM_aa',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::BuildHMM',
            -parameters => {
                'hmmer_home'        => $self->o('hmmer2_home'),
                'hmmer_version'     => 2,
            },
            -hive_capacity        => $self->o('build_hmm_capacity'),
            -batch_size           => 5,
            -priority             => -10,
            -rc_name => '500Mb_job',
        },

        {   -logic_name => 'build_HMM_cds',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::BuildHMM',
            -parameters => {
                'cdna'              => 1,
                'hmmer_home'        => $self->o('hmmer2_home'),
                'hmmer_version'     => 2,
            },
            -hive_capacity        => $self->o('build_hmm_capacity'),
            -batch_size           => 5,
            -priority             => -10,
            -rc_name => '1Gb_job',
        },

# ---------------------------------------------[Quick tree break steps]-----------------------------------------------------------------------

        {   -logic_name => 'quick_tree_break',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::QuickTreeBreak',
            -parameters => {
                'quicktree_exe'     => $self->o('quicktree_exe'),
                'treebreak_gene_count'  => $self->o('treebreak_gene_count'),
            },
            -hive_capacity        => $self->o('quick_tree_break_capacity'),
            -rc_name   => '2Gb_job',
            -flow_into => [ 'other_paralogs' ],
        },

        {   -logic_name     => 'other_paralogs',
            -module         => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::OtherParalogs',
            -parameters     => {
                'dataflow_subclusters' => 1,
            },
            -hive_capacity  => $self->o('other_paralogs_capacity'),
            -rc_name        => '250Mb_job',
            -flow_into      => {
                2 => [ 'tree_backup' ],
            }
        },

        {   -logic_name    => 'tree_backup',
            -module        => 'Bio::EnsEMBL::Hive::RunnableDB::SqlCmd',
            -parameters    => {
                'sql'         => 'INSERT INTO gene_tree_backup (seq_member_id, root_id) SELECT seq_member_id, root_id FROM gene_tree_node WHERE seq_member_id IS NOT NULL AND root_id = #gene_tree_id#',
            },
            -analysis_capacity => 1,
            -meadow_type    => 'LOCAL',
            -flow_into      => [ 'alignment_entry_point' ],
        },



# -------------------------------------------[name mapping step]---------------------------------------------------------------------

        {
            -logic_name => 'stable_id_mapping',
            -module => 'Bio::EnsEMBL::Compara::RunnableDB::StableIdMapper',
            -parameters => {
                'prev_rel_db'   => '#reuse_db#',
                'type'          => 't',
            },
            -rc_name => '1Gb_job',
        },

        {   -logic_name    => 'treefam_xref_idmap',
            -module        => 'Bio::EnsEMBL::Compara::RunnableDB::TreefamXrefMapper',
            -parameters    => {
                'tf_release'  => $self->o('tf_release'),
                'tag_prefix'  => '',
            },
            -rc_name => '1Gb_job',
        },

# ---------------------------------------------[homology step]-----------------------------------------------------------------------

        {   -logic_name => 'group_genomes_under_taxa',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::GroupGenomesUnderTaxa',
            -parameters => {
                'taxlevels'             => $self->o('taxlevels'),
                'filter_high_coverage'  => $self->o('filter_high_coverage'),
            },
            -flow_into => {
                2 => [ 'mlss_factory' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'mlss_factory',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::MLSSIDFactory',
            -flow_into => {
                2 => [ 'homology_factory' ],
            },
            -meadow_type    => 'LOCAL',
        },

        {   -logic_name => 'homology_factory',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::HomologyGroupingFactory',
            -hive_capacity => $self->o('homology_dNdS_capacity'),
            -flow_into => {
                'A->1' => [ 'hc_dnds' ],
                '2->A' => [ 'homology_dNdS' ],
            },
        },

        {   -logic_name => 'homology_dNdS',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::Homology_dNdS',
            -parameters => {
                'codeml_parameters_file'    => $self->o('codeml_parameters_file'),
                'codeml_exe'                => $self->o('codeml_exe'),
            },
            -hive_capacity        => $self->o('homology_dNdS_capacity'),
            -failed_job_tolerance => 2,
            -rc_name => '500Mb_job',
        },

        {   -logic_name         => 'hc_dnds',
            -module             => 'Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::SqlHealthChecks',
            -parameters         => {
                mode            => 'homology_dnds',
            },
            -flow_into          => [ 'threshold_on_dS' ],
            %hc_analysis_params,
        },

        {   -logic_name => 'threshold_on_dS',
            -module     => 'Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::Threshold_on_dS',
            -hive_capacity => $self->o('homology_dNdS_capacity'),
        },

    ];
}

sub pipeline_analyses {
    my $self = shift;

    ## The analysis defined in this file
    my $all_analyses = $self->core_pipeline_analyses(@_);
    ## We add some more analyses
    push @$all_analyses, @{$self->extra_analyses(@_)};

    my %analyses_by_name = map {$_->{'-logic_name'} => $_} @$all_analyses;
    $self->tweak_analyses(\%analyses_by_name);

    return $all_analyses;
}


## The following methods can be redefined to add more analysis and change the parameters of some core ones
sub extra_analyses {
    my $self = shift;
    return [
    ];
}

sub tweak_analyses {
    my $self = shift;
    my $analyses_by_name = shift;
}

1;

