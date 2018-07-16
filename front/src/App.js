import React, { Component } from 'react';
import reactLogo from './assets/images/react-logo.svg';
import dockerLogo from './assets/images/docker-logo.svg';
import gopher from './assets/images/gopher.svg';
import './App.css';
import axios from 'axios';

class App extends Component {
  state = {
    loading: false,
    error: null,
    data: null
  }
  componentDidMount() {
    this.fetchInfos()
  }
  fetchInfos() {
    this.setState({
      error: null,
      loading: true,
      data: null
    });
    axios.get('/api').then(result => {
      this.setState({
        data: result.data,
        loading: false
      })
    })
    .catch(error => {
      this.setState({
        error,
        loading: false
      })
    })
  }
  render() {
    const {loading, error, data} = this.state;
    return (
      <div className="App">
        <header className="App-header">
          <img src={dockerLogo} className="App-logo" alt="logo" />
          <img src={reactLogo} className="App-logo" alt="logo" />
          <img src={gopher} style={{marginLeft: 12}} className="App-logo" alt="logo" />
          <h1 className="App-title">my-docker-fullstack-project</h1>
        </header>
        <p>Basic infos retrieved from the dockerized golang api:</p>
        {loading && <p>Loading ...</p>}
        {error && <p>An error occured</p>}
        {data && <ul style={{listStyle: "none", paddingLeft: 0}}>{Object.entries(data).map(([key, value]) => <li key={key}>
          <strong>{key}</strong>: <span>{value}</span>
        </li>)}</ul>}
        <p><button onClick={() => this.fetchInfos()}>Reload</button></p>
      </div>
    );
  }
}

export default App;
