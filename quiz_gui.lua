local basalt = require("/basalt")

local questions = {
  {
    question = "¿Cuál es la capital de Francia?",
    options = {"Berlín", "Madrid", "París", "Roma"},
  },
  {
    question = "¿Cuál de estos es una fruta?",
    options = {"Zanahoria", "Patata", "Manzana", "Lechuga"},
  },
  {
    question = "¿Cuántas patas tiene una araña?",
    options = {"6", "8", "10", "4"},
  }
}

local answers = {}
local currentQuestion = 1

local main = basalt.createFrame()
local questionLabel = main:addLabel():setText(""):setPosition(2, 2):setSize(50, 1)
local resultLabel = main:addLabel():setText(""):setPosition(2, 10):setSize(50, 2):hide()
local optionButtons = {}

-- Crear botones de opciones
for i = 1, 4 do
  optionButtons[i] = main:addButton()
    :setPosition(4, 3 + i)
    :setSize(40, 1)
    :onClick(function()
      local q = questions[currentQuestion]
      table.insert(answers, q.options[i])
      currentQuestion = currentQuestion + 1
      if currentQuestion <= #questions then
        showQuestion(currentQuestion)
      else
        showResult()
      end
    end)
end

-- Mostrar una pregunta
function showQuestion(index)
  local q = questions[index]
  questionLabel:setText("Pregunta " .. index .. ": " .. q.question)
  resultLabel:hide()
  for i, btn in ipairs(optionButtons) do
    if q.options[i] then
      btn:setText(i .. ") " .. q.options[i]):show()
    else
      btn:hide()
    end
  end
end

-- Mostrar resultados y crear el libro
function showResult()
  questionLabel:setText("¡Quiz completado!")
  for _, btn in ipairs(optionButtons) do
    btn:hide()
  end

  -- Guardar en archivo
  local file = fs.open("quiz_result.txt", "w")
  file.writeLine("=== Resultados del Quiz ===")
  for i, q in ipairs(questions) do
    file.writeLine("Q: " .. q.question)
    file.writeLine("A: " .. answers[i])
    file.writeLine("")
  end
  file.close()

  -- Intentar imprimir
  local printer = peripheral.find("printer")
  if printer then
    if printer.getInkLevel() > 0 and printer.getPaperLevel() > 0 then
      printer.newPage()
      printer.setPageTitle("Resultados del Quiz")
      for i, q in ipairs(questions) do
        printer.write("Q: " .. q.question .. "\n")
        printer.write("A: " .. answers[i] .. "\n\n")
      end
      printer.endPage()
      resultLabel:setText("📘 Resultado impreso y guardado."):show()
    else
      resultLabel:setText("⚠️ Impresora sin tinta o papel. Solo guardado."):show()
    end
  else
    resultLabel:setText("✅ Resultado guardado. (quiz_result.txt)"):show()
  end
end

showQuestion(currentQuestion)
basalt.autoUpdate()
