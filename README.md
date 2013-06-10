## create_short_videos.pl

- ffmpegを利用して対象動画から複数のセグメントビデオを生成する．

- 各セグメントの開始時間・終了時間をテキストファイルにCSV形式記載する必要あり．

### Usage

    perl create_short_videos.pl [input.mpg] [segments.txt] [output_path]

### Example

    perl create_short_videos.pl video.mpg segments.txt training


