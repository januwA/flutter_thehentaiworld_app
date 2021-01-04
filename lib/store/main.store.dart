class MainStore {
  /// 控制视频是否播放声音
  bool openVolume = false;

  setOpenVolume(double volume) {
    openVolume = volume != 0.0 ? true : false;
  }
}
