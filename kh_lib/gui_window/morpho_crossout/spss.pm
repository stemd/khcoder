package gui_window::morpho_crossout::spss;
use base qw(gui_window::morpho_crossout);
use strict;


#----------#
#   �¹�   #

sub save{
	my $self = shift;
	
	unless ( eval(@{$self->hinshi}) ){
		gui_errormsg->open(
			type => 'msg',
			msg  => '�ʻ줬1�Ĥ����򤵤�Ƥ��ޤ���',
		);
		return 0;
	}
	
	# ��¸��λ���
	my @types = (
		[ "spss syntax file",[qw/.sps/] ],
		["All files",'*']
	);
	my $path = $self->win_obj->getSaveFile(
		-defaultextension => '.sps',
		-filetypes        => \@types,
		-title            =>
			$self->gui_jchar('��ʸ�����и��ɽ��̾�����դ�����¸'),
		-initialdir       => $self->gui_jchar($::config_obj->cwd),
	);
	unless ($path){
		return 0;
	}
	$path = gui_window->gui_jg($path);
	$path = $::config_obj->os_path($path);
	
	my $ans = $self->win_obj->messageBox(
		-message => $self->gui_jchar
			(
			   "���ν����ˤϻ��֤������뤳�Ȥ�����ޤ���\n".
			   "³�Ԥ��Ƥ�������Ǥ�����"
			),
		-icon    => 'question',
		-type    => 'OKCancel',
		-title   => 'KH Coder'
	);
	unless ( $ans =~ /ok/i ){ return 0; }
	
	my $w = gui_wait->start;
	mysql_crossout::spss->new(
		tani   => $self->tani,
		hinshi => $self->hinshi,
		max    => $self->max,
		min    => $self->min,
		max_df => $self->max_df,
		min_df => $self->min_df,
		file   => $path,
	)->run;
	$w->end;
	
	$self->close;
}

#--------------#
#   ��������   #


sub label{
	return '��ʸ�����и��ɽ�ν��ϡ� SPSS';
}

sub win_name{
	return 'w_morpho_crossout_spss';
}

1;