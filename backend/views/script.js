
document.getElementById('clickMeButton').addEventListener('click', function() {
    fetch('http://localhost:8080/api/website/incrementTotalClick', {
      method: 'POST', 
    })
    .then(() => fetch('http://localhost:8080/api/website/getTotalClick'))
    .then(response => response.json())
    .then(data => {
      document.getElementById('totalClicks').textContent = 'Global Click Count: ' + data.totalClickCount;
    })
    .catch((error) => {
      console.error('Error:', error);
    });
  });

window.onload = function() {
    fetch('http://localhost:8080/api/website/getTotalClick')
      .then(response => response.json())
      .then(data => {
        document.getElementById('totalClicks').textContent += data.totalClickCount;
      })
      .catch((error) => {
        console.error('Error:', error);
      });
  };