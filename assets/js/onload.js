(function () {
    const body = document.body
    window.CAMUS_THEME = body ? (body.getAttribute("data-camus-theme") || "") : ""

    window.CAMUS_TOMATO = {
        volume: {enabled: false},
        month: {enabled: true},
        reverse: {enabled: false, default: false},
        index: {enabled: true, default: true},
        font: {
            family: '"PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", "Noto Sans SC", system-ui, -apple-system, sans-serif',
            size: 14
        }
    }
})()
