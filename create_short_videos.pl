use strict;
use warnings;
use Text::CSV_XS;
use Time::Piece;

# 指定した動画から複数の秒数を指定，その間の動画を生成
# ffmpeg利用


# 1つの動画に対して1つの短い動画を生成
sub create_short_video {
  my ($input_video_path, $time_segment_ref, $output_path) = @_;

  my $ext;

  # パスを除いたファイル名の取得
  my $input_video;
  if( $input_video_path =~ m|.*/(.*)$|i ) {
    $input_video = $1;
  }

  # 拡張子取得
  ($ext = $input_video) =~ s/^.*\.(.*)$/$1/;

  # 拡張子を取り除いたファイル名
  my $input_video_non_ext = $input_video;
  $input_video_non_ext =~ s/^(.*)\..*$/$1/; 

  if ($ext eq '') {
    print "### Error :No extension found for input file." . "\n";
    return;
  }

  my $start = $time_segment_ref->{start};
  my $end   = $time_segment_ref->{end};
  my $output_video = $input_video_non_ext . "_" . $start->hms("_") . "_to_" . $end->hms("_") . "." . $ext;

  # FIXME: 開始時間を秒数で表す
  my $zero_time = Time::Piece->strptime('00:00:00', '%H:%M:%S');
  my $start_sec = $start - $zero_time;

  # durationの計算
  # Note: Time::Pieceオブジェクト同時の引き算の戻り値はTime::Secondsオブジェクトになる
  my $duration_sec = $end - $start;

  my $command = "ffmpeg -i " . $input_video_path . " -qscale 0 -ss " . $start_sec
    . " -t " . $duration_sec . " " . $output_path . "/" .  $output_video;
  print "### Command: ". $command . "\n";

  # 実行
  system($command);
}


# 動画生成用メイン関数
# 1つの動画に対して複数の短い動画生成
# Input :対象動画ファイル名 
#        開始と終了時間をcsv形式で記入したファイルパス
#        生成場所のパス
sub create_short_videos {
  my ($input_video, $info_file, $output_path) = @_;

  # テキストファイルを解析
  open(my $fh, "<", $info_file)
    or die "Cannot open $info_file: $!";

  # 行ごとに読み込み
  while(my $line = readline $fh){ 
    chomp $line;  
    # 行ごとにcsvとして解析
    my $csv = Text::CSV_XS->new ({ binary => 1});

    my $status = $csv->parse($line);
    my @elements = $csv->fields();
   
    # 時間表記を秒数に変換が必要
    my $start_time = Time::Piece->strptime($elements[0], '%H:%M:%S');
    my $end_time   = Time::Piece->strptime($elements[1], '%H:%M:%S');

    my $time_segment = {
      start => $start_time,
      end   => $end_time
    };

    # この区間の動画を生成
    &create_short_video($input_video, $time_segment, $output_path);
  }
  close $fh;
}

if ($#ARGV != 2) {
  print "Usage: perl create_short_videos.pl [input.mpg] [segments.txt] [output_path/]" . "\n";
  print "Ex: perl create_short_videos.pl ../die_hard.mpg segments.txt training" . "\n";
  exit; 
}


### main
&create_short_videos($ARGV[0], $ARGV[1], $ARGV[2]);

