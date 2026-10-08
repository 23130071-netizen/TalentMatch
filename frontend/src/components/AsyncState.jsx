export default function AsyncState({loading,error,empty,emptyTitle='Chưa có dữ liệu',emptyText='Khi có dữ liệu, nội dung sẽ xuất hiện tại đây.',children,onRetry}){
  if(loading)return <div className="state"><div className="spinner"/><p>Đang tải dữ liệu…</p></div>;
  if(error)return <div className="state state-error"><h3>Không thể tải dữ liệu</h3><p>{error}</p>{onRetry&&<button onClick={onRetry}>Thử lại</button>}</div>;
  if(empty)return <div className="state"><h3>{emptyTitle}</h3><p>{emptyText}</p></div>;
  return children;
}
