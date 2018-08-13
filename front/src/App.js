import React, { Component } from 'react';
import reactLogo from './assets/images/react-logo.svg';
import dockerLogo from './assets/images/docker-logo.svg';
import nginxLogo from './assets/images/nginx-logo.svg';
import kubernetesLogo from './assets/images/kubernetes-logo.svg';
import gopher from './assets/images/gopher.svg';
import './App.css';
import axios from 'axios';

const CancelToken = axios.CancelToken;
const source = CancelToken.source();

class App extends Component {
  state = {
    loading: false,
    error: null,
    data: null
  }
  componentDidMount() {
    this.fetchInfos()
  }
  componentWillUnmount() {
    source.cancel({
      type: "componentWillUnmount",
      message:"Component unmounting, cancelling inflight requests"
    });
  }
  fetchInfos() {
    this.setState({
      error: null,
      loading: true,
      data: null
    });
    axios.get('/api', { cancelToken: source.token }).then(result => {
      this.setState({
        data: result.data,
        loading: false
      })
    })
    .catch(error => {
      if (axios.isCancel(error) && error.message && error.message.type === "componentWillUnmount") {
        console.error(error.message.message);
      }
      else {
        this.setState({
          error,
          loading: false
        });
      }
    })
  }
  exit() {
    axios.get('/api/exit');
  }
  render() {
    const {loading, error, data} = this.state;
    return (
      <div className="App">
        <header className="App-header">
          <img src={kubernetesLogo} style={{marginRight: 20}} className="App-logo" alt="kubernetes logo" />
          <img src={dockerLogo} className="App-logo" alt="docker logo" />
          <img src={reactLogo} className="App-logo" alt="react logo" />
          <img src={nginxLogo} style={{marginRight: 20}} className="App-logo" alt="nginx logo" />
          <img src={gopher} style={{marginLeft: 12}} className="App-logo" alt="golang logo" />
          <h1 className="App-title">my-docker-fullstack-project</h1>
          <p className="App-github-link"><a href="https://github.com/topheman/my-docker-fullstack-project" title="Sources on github">sources on github</a></p>
        </header>
        <p>Basic infos retrieved from the dockerized golang api:</p>
        {loading && <p>Loading ...</p>}
        {error && <p>An error occured</p>}
        {data && <ul style={{listStyle: "none", paddingLeft: 0}}>{Object.entries(data).map(([key, value]) => <li key={key}>
          <strong>{key}</strong>: <span>{key !== 'uptime' ? value : `${parseInt(value, 10)}s`}</span>
        </li>)}</ul>}
        <p>
          <button onClick={() => this.fetchInfos()} className="App-button">Reload infos</button>       
        </p>
        {process.env.NODE_ENV === 'production' && <p>
          <a onClick={() => this.exit()} className="App-button"><code>exit 1</code> the api server</a> and see the container restart the api server on failure, thanks to docker-compose or kubernetes (reload infos to check uptime).
        </p>}
      </div>
    );
  }
}

export default App;
