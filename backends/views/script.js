
document.getElementById('clickMeButton').addEventListener('click', function() {
    fetch('https://BroncoBond.com/api/website/incrementTotalClick', {
      method: 'POST', 
    })
    .then(() => fetch('https://BroncoBond.com/api/website/getTotalClick'))
    .then(response => response.json())
    .then(data => {
      document.getElementById('totalClicks').textContent = 'Global Click Count: ' + data.totalClickCount;
    })
    .catch((error) => {
      console.error('Error:', error);
    });
  });

window.onload = function() {
    fetch('https://BroncoBond.com/api/website/getTotalClick')
      .then(response => response.json())
      .then(data => {
        document.getElementById('totalClicks').textContent += data.totalClickCount;
      })
      .catch((error) => {
        console.error('Error:', error);
      });
  };