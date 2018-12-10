  $('.gridly').gridly({
    base: 60, // px 
    gutter: 20, // px
    columns: 12
  });
  $(function() {
    var ctx = document.getElementById("lineChart");
    var myChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: ["Red", "Blue", "Yellow", "Green", "Purple", "Orange"],
            datasets: [{
                label: '# of Votes',
                backgroundColor: "rgba(155, 89, 182,0.2)",
                borderColor: "rgba(142, 68, 173,1.0)",
                pointBackgroundColor: "rgba(142, 68, 173,1.0)",
                data: [12, 19, 3, 5, 2, 3]
            }]
        },
        options: {
            scales: {
                yAxes: [{
                    ticks: {
                        beginAtZero:true
                    }
                }]
            },
            pan: {
                enabled: true,
                mode: 'xy'
            },
            zoom: {
                enabled: true,
                mode: 'xy',
            }
        }
    })
});
$(function() {
  var ctx1 = document.getElementById("barChart");
  var myChart1 = new Chart(ctx1, {
    type: 'bar',
    data: {
      labels: ["Africa", "Asia", "Europe", "Latin America", "North America"],
      datasets: [
        {
          label: "Population (millions)",
          backgroundColor: ["#3e95cd", "#8e5ea2","#3cba9f","#e8c3b9","#c45850"],
          data: [2478,5267,734,784,433]
        }
      ]
    },
    options: {
      legend: { display: false },
      title: {
        display: true,
        text: 'Predicted world population (millions) in 2050'
      },
    pan: {
      enabled: true,
      mode: 'xy'
  },
  zoom: {
      enabled: true,
      mode: 'xy',
  }
}
  })
});
