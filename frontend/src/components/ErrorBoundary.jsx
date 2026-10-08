import React from 'react';
export default class ErrorBoundary extends React.Component {
  constructor(props){super(props);this.state={error:null}}
  static getDerivedStateFromError(error){return{error}}
  componentDidCatch(error,info){console.error('UI crash',error,info)}
  render(){if(this.state.error)return <div className="state state-error"><h2>Trang gặp sự cố</h2><p>Không thể hiển thị nội dung này. Dữ liệu của bạn chưa bị thay đổi.</p><button onClick={()=>this.setState({error:null})}>Thử lại</button></div>;return this.props.children}
}
