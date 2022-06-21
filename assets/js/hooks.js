import RealtimeLineChart from './line_chart';
import StaticMap from './static_map';

const Hooks = {};

Hooks.LineChart = {
  mounted() {
    // グラフを初期化する。
    this.chart = new RealtimeLineChart(this.el);

    this.imsi = this.el.dataset.imsi;

    // LiveViewから'new-point'イベントを受信時、座標を追加する。
    this.handleEvent(`new-point-${this.imsi}`, ({ label, value, insertedAt }) => {
      this.chart.addPoint(label, value, insertedAt);
    });
  },
  destroyed() {
    // 使用後はちゃんと破壊する。
    this.chart.destroy();
  },
};

Hooks.StaticMap = {
  mounted() {
    const sampleImage = document.getElementById('sampleImage');
    const markerMaps = JSON.parse(this.el.dataset.markers);
    this.staticMap = new StaticMap(sampleImage, markerMaps);

    this.handleEvent('update-point', ({ imsi, distance, capacity_rate }) => {
      this.staticMap.updatePoint(imsi, distance, capacity_rate);
    });
  },
};

export default Hooks;
