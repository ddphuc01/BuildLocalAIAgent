import React, { useEffect, useRef, useState } from 'react'

const Chat: React.FC<{ backendUrl: string }> = ({ backendUrl }) => {
  const [messages, setMessages] = useState<{ role: 'user' | 'assistant'; content: string }[]>([])
  const [input, setInput] = useState('')
  const wsRef = useRef<WebSocket | null>(null)

  useEffect(() => {
    const wsUrl = backendUrl.replace('http', 'ws') + '/ws/chat'
    const ws = new WebSocket(wsUrl)
    wsRef.current = ws
    ws.onmessage = (ev) => setMessages((m) => [...m, { role: 'assistant', content: ev.data }])
    return () => ws.close()
  }, [backendUrl])

  const send = () => {
    if (!input.trim()) return
    setMessages((m) => [...m, { role: 'user', content: input }])
    wsRef.current?.send(input)
    setInput('')
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', borderLeft: '1px solid #333' }}>
      <div style={{ flex: 1, padding: 8, overflow: 'auto' }}>
        {messages.map((m, i) => (
          <div key={i} style={{ marginBottom: 8, color: m.role === 'user' ? '#fff' : '#9feaf9' }}>
            <b>{m.role}:</b> {m.content}
          </div>
        ))}
      </div>
      <div style={{ display: 'flex', gap: 8, padding: 8 }}>
        <input style={{ flex: 1 }} value={input} onChange={(e) => setInput(e.target.value)} placeholder="Ask AI..." />
        <button onClick={send}>Send</button>
      </div>
    </div>
  )
}

export default Chat


