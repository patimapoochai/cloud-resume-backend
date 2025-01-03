// TODO: tests to write
// - can the api endpoint handles when there is no X-Forwarded-For header? (is this needed?)
//

describe('E2E website', () => {
  const apiUrl = "https://resumeapi.patimapoochai.net/visitor";
  it('can get visitor from API', () => {
    cy.request("POST",
      apiUrl)
      .then(res => {
        expect(res.status).to.eq(200);
        expect(res.body).to.be.a('object');
      })
  })

  it('increments the visitor count each visit', () => {
    let visitorCount;

    cy.request("POST",
      apiUrl)
      .then(res => {
        visitorCount = +res.body.VisitorCount;
      });

    cy.request("POST",
      apiUrl)
      .then(res => {
        // console.log(visitorCount + " vs " + res.body.VisitorCount);
        expect(res.body.VisitorCount > visitorCount, 'Visitor count isn\'t more than previous value')
          .to.eq(true);
      });
  })

  it('remembers your IP address', () => {
    let uniqueVisitorCount;

    cy.request("POST",
      apiUrl,
      { "queryType": "unique" }
    )
      .then(res => {
        console.log(res);
        uniqueVisitorCount = +res.body.VisitorCount;
      });

    cy.request("POST",
      apiUrl,
      { "queryType": "unique" }
    )
      .then(res => {
        expect(res.body.VisitorCount == uniqueVisitorCount, 'Visitor count isn\'t more than previous value')
          .to.eq(true);
      });
  })

  it('rejects malformed POST requests', () => {
    cy.request({
      method: 'POST',
      url: apiUrl,
      body: { "queryType": "uniq" },
      failOnStatusCode: false,
    }).then(res => {
      expect(res.status).to.be.gt(399);
    })

    cy.request({
      method: 'POST',
      url: apiUrl,
      body: { "querType": "unique" },
      failOnStatusCode: false,
    }).then(res => {
      expect(res.status).to.be.gt(399);
    })

    cy.request({
      method: 'POST',
      url: apiUrl,
      body: "bad",
      failOnStatusCode: false,
    }).then(res => {
      expect(res.status).to.be.gt(399);
    })
  })
})

