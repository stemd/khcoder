package gui_window::r_plot_opt::cod_netg;
use base qw(gui_window::r_plot_opt);

sub innner{
	my $self = shift;
	my $lf = $self->{labframe};

	# ����μ���
	my ($edges, $th);
	if ($self->{command_f} =~ /edges <- ([0-9\.]+)\n/){
		$edges = $1;
	} else {
		die("cannot get configuration: edges");
	}
	if ($self->{command_f} =~ /th <- ([0-9\.]+)\n/){
		$th = $1;
	} else {
		die("cannot get configuration: th");
	}
	if ($self->{command_f} =~ /use_freq_as_size <- ([01])\n/){
		$self->{check_use_freq_as_size} = $1;
	} else {
		die("cannot get configuration: use_freq_as_size");
	}
	if ($self->{command_f} =~ /use_weight_as_width <- ([01])\n/){
		$self->{check_use_weight_as_width} = $1;
	} else {
		die("cannot get configuration: $use_weight_as_width");
	}

	if ($edges == 0){
		$self->{radio} = 'j';
		if ($self->{command_f} =~ /# edges: ([0-9]+)\n/){
			$edges = $1;
		} else {
			die("cannot get configuration: edges 2");
		}
	} else {
		$self->{radio} = 'n';
		if ($self->{command_f} =~ /# min. jaccard: ([0-9\.]+)\n/){
			$th = $1;
		} else {
			die("cannot get configuration: edges 2");
		}
	}

	# edge����
	$lf->Label(
		-text => $self->gui_jchar('���褹�붦���ط���edge��'),
		-font => "TKFN",
	)->pack(-anchor => 'w');

	my $f4 = $lf->Frame()->pack(
		-fill => 'x',
		-pady => 2
	);

	$f4->Label(
		-text => '  ',
		-font => "TKFN",
	)->pack(-anchor => 'w', -side => 'left');

	$f4->Radiobutton(
		-text             => $self->gui_jchar('�������'),
		-font             => "TKFN",
		-variable         => \$self->{radio},
		-value            => 'n',
		-command          => sub{ $self->refresh;},
	)->pack(-anchor => 'w', -side => 'left');

	$self->{entry_edges_number} = $f4->Entry(
		-font       => "TKFN",
		-width      => 3,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_edges_number}->insert(0,$edges);
	$self->{entry_edges_number}->bind("<Key-Return>",sub{$self->calc;});
	$self->config_entry_focusin($self->{entry_edges_number});

	$f4->Radiobutton(
		-text             => $self->gui_jchar('Jaccard������'),
		-font             => "TKFN",
		-variable         => \$self->{radio},
		-value            => 'j',
		-command          => sub{ $self->refresh;},
	)->pack(-anchor => 'w', -side => 'left');

	$self->{entry_edges_jac} = $f4->Entry(
		-font       => "TKFN",
		-width      => 6,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_edges_jac}->insert(0,$th);
	$self->{entry_edges_jac}->bind("<Key-Return>",sub{$self->calc;});
	$self->config_entry_focusin($self->{entry_edges_jac});

	$f4->Label(
		-text => $self->gui_jchar('�ʾ�'),
		-font => "TKFN",
	)->pack(-anchor => 'w', -side => 'left');

	$lf->Checkbutton(
			-text     => $self->gui_jchar('���������ط��ۤ���������','euc'),
			-variable => \$self->{check_use_weight_as_width},
			-anchor => 'w',
	)->pack(-anchor => 'w');

	$lf->Checkbutton(
			-text     => $self->gui_jchar('�и�����¿�������ɤۤ��礭������','euc'),
			-variable => \$self->{check_use_freq_as_size},
			-anchor => 'w',
	)->pack(-anchor => 'w');

	$self->refresh(3);
	return $self;
}

sub refresh{
	my $self = shift;
		
	my ($dis, $nor);
	if ($self->{radio} eq 'n'){
		$nor = $self->{entry_edges_number};
		$dis = $self->{entry_edges_jac};
	} else {
		$nor = $self->{entry_edges_jac};
		$dis = $self->{entry_edges_number};
	}

	$nor->configure(-state => 'normal' , -background => 'white');
	$dis->configure(-state => 'disable', -background => 'gray' );
	
	$nor->focus unless $_[0] == 3;
}

sub calc{
	my $self = shift;

	my $r_command = '';
	if ($self->{command_f} =~ /\A(.+)# END: DATA.+/s){
		$r_command = $1;
		#print "chk: $r_command\n";
		$r_command = Jcode->new($r_command)->euc
			if $::config_obj->os eq 'win32';
	} else {
		gui_errormsg->open(
			type => 'msg',
			msg  => 'Ĵ���˼��Ԥ��ޤ��ޤ�����',
		);
		print "$self->{command_f}\n";
		$self->close;
		return 0;
	}

	$r_command .= "# END: DATA\n";

	my $fontsize = $self->gui_jg( $self->{entry_font_size}->get );
	$fontsize /= 100;

	&gui_window::word_netgraph::make_plot(
		font_size      => $fontsize,
		plot_size      => $self->gui_jg( $self->{entry_plot_size}->get ),
		n_or_j         => $self->gui_jg( $self->{radio} ),
		edges_num      => $self->gui_jg( $self->{entry_edges_number}->get ),
		edges_jac      => $self->gui_jg( $self->{entry_edges_jac}->get ),
		use_freq_as_size => $self->gui_jg( $self->{check_use_freq_as_size} ),
		use_weight_as_width =>
			$self->gui_jg( $self->{check_use_weight_as_width} ),
		r_command      => $r_command,
		plotwin_name   => 'cod_netg',
	);

	$self->close;

}

sub win_title{
	return '�����ǥ��󥰡������ͥåȥ����Ĵ��';
}

sub win_name{
	return 'w_cod_netg_plot_opt';
}

1;