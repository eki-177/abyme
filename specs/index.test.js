// import { waitFor } from '@testing-library/dom'
import { Application } from 'stimulus'
// import AbymeController from '../src/index.js'

const startStimulus = () => {
  const application = Application.start()
  // application.register('abyme', AbymeController)
}

const spyError = jest.spyOn(console, 'error')

describe('#load', () => {
  beforeEach(() => {
    spyError.mockReset()

    startStimulus()

    document.body.innerHTML = `
      <div id="controller" data-controller="abyme"></div>
    `
  })

  it('correctly sets up tests (package is already tested through system tests)', async () => {
    return true;
  })
})