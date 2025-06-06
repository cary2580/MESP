!/**
 * Highstock JS v12.1.2 (2025-01-09)
 * @module highcharts/indicators/obv
 * @requires highcharts
 * @requires highcharts/modules/stock
 *
 * Indicator series type for Highcharts Stock
 *
 * (c) 2010-2024 Karol Kolodziej
 *
 * License: www.highcharts.com/license
 */function(e,t){"object"==typeof exports&&"object"==typeof module?module.exports=t(e._Highcharts,e._Highcharts.SeriesRegistry):"function"==typeof define&&define.amd?define("highcharts/indicators/obv",["highcharts/highcharts"],function(e){return t(e,e.SeriesRegistry)}):"object"==typeof exports?exports["highcharts/indicators/obv"]=t(e._Highcharts,e._Highcharts.SeriesRegistry):e.Highcharts=t(e.Highcharts,e.Highcharts.SeriesRegistry)}("undefined"==typeof window?this:window,(e,t)=>(()=>{"use strict";var r={512:e=>{e.exports=t},944:t=>{t.exports=e}},s={};function o(e){var t=s[e];if(void 0!==t)return t.exports;var i=s[e]={exports:{}};return r[e](i,i.exports,o),i.exports}o.n=e=>{var t=e&&e.__esModule?()=>e.default:()=>e;return o.d(t,{a:t}),t},o.d=(e,t)=>{for(var r in t)o.o(t,r)&&!o.o(e,r)&&Object.defineProperty(e,r,{enumerable:!0,get:t[r]})},o.o=(e,t)=>Object.prototype.hasOwnProperty.call(e,t);var i={};o.d(i,{default:()=>v});var a=o(944),n=o.n(a),h=o(512),u=o.n(h);let{sma:p}=u().seriesTypes,{isNumber:d,error:c,extend:l,merge:f}=n();class g extends p{getValues(e,t){let r=e.chart.get(t.volumeSeriesID),s=e.xData,o=e.yData,i=[],a=[],n=[],h=!d(o[0]),u=[],p=1,l=0,f=0,g=0,v=0,y;if(r)for(y=r.getColumn("y"),u=[s[0],l],g=h?o[0][3]:o[0],i.push(u),a.push(s[0]),n.push(u[1]);p<o.length;p++)f=(v=h?o[p][3]:o[p])>g?l+y[p]:v===g?l:l-y[p],u=[s[p],f],l=f,g=v,i.push(u),a.push(s[p]),n.push(u[1]);else{c("Series "+t.volumeSeriesID+" not found! Check `volumeSeriesID`.",!0,e.chart);return}return{values:i,xData:a,yData:n}}}g.defaultOptions=f(p.defaultOptions,{marker:{enabled:!1},params:{index:void 0,period:void 0,volumeSeriesID:"volume"},tooltip:{valueDecimals:0}}),l(g.prototype,{nameComponents:void 0}),u().registerSeriesType("obv",g);let v=n();return i.default})());