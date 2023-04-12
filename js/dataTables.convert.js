const issueCells = document.querySelectorAll('#issues tbody td:nth-child(5)');

issueCells.forEach(cell => {
  const issueNumber = cell.textContent.replace('#', '');
  const issueUrl = `https://github.com/NorESMhub/noresm2cmor/issues/${issueNumber}`;

  const link = document.createElement('a');
  link.href = issueUrl;
  link.textContent = `#${issueNumber}`;

  cell.innerHTML = '';
  cell.appendChild(link);
});

