  $('.gridly').gridly({
    base: 60, // px 
    gutter: 20, // px
    columns: 12
  });
  $(function() {
  var ctx1 = document.getElementById("lineChart").getContext('2d');
  var myChart1 = new Chart(ctx1, {
   type: 'line',
    data: {
       labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
     datasets: [
       {
        label: "Total Bitcoins mined",
        backgroundColor: "rgba(155, 89, 182,0.2)",
        borderColor: "rgba(142, 68, 173,1.0)",
        pointBackgroundColor: "rgba(142, 68, 173,1.0)",
        data: [2.3,2.5,2.7,3.3,4.3,5.3,2.3,2.7,2.8,2.3,3.3,5.3]
       }
      ]
    },
    options: {
     scales: {
      yAxes: [{
       ticks: {
        beginAtZero:true
       }
      }]
     }
    }
  })
});
$(function() {
  var ctx2 = document.getElementById("barChart").getContext('2d');
  var myChart2 = new Chart(ctx2, {
   type: 'line',
    data: {
       labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
     datasets: [
       {
        label: "Total Bitcoins mined",
        backgroundColor: "rgba(155, 89, 182,0.2)",
        borderColor: "rgba(142, 68, 173,1.0)",
        pointBackgroundColor: "rgba(142, 68, 173,1.0)",
        data: [2.3,2.5,2.7,3.3,4.3,5.3,2.3,2.7,2.8,2.3,3.3,5.3]
       }
      ]
    },
    options: {
     scales: {
      yAxes: [{
       ticks: {
        beginAtZero:true
       }
      }]
     }
    }
  })
});
