document.getElementById('upload-form').addEventListener('submit', function(e) {
    e.preventDefault();
    const fileInput = document.getElementById('log-file');
    const loader = document.getElementById('loader');
    const resultDiv = document.getElementById('result');
    resultDiv.innerHTML = ''; // Clear previous results

    if (fileInput.files.length === 0) {
        alert('Please select a file.');
        return;
    }

    const file = fileInput.files[0];
    const reader = new FileReader();

    reader.onload = function(event) {
        const logContent = event.target.result;
        // Display loader
        loader.style.display = 'block';

        // Send logContent to the server for AI analysis
        fetch('/analyze', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ log: logContent })
        })
        .then(response => response.json())
        .then(data => {
            loader.style.display = 'none';
            resultDiv.innerText = data.analysis;
        })
        .catch(error => {
            loader.style.display = 'none';
            console.error('Error:', error);
            alert('An error occurred while analyzing the logs.');
        });
    };

    reader.readAsText(file);
});
