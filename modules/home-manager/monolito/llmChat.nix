{ pkgs }:

let
  # Bundle all dependencies
  llm-chat-deps = pkgs.symlinkJoin {
    name = "llm-chat-deps";
    paths = with pkgs; [
      curl
      jq
      pass
      glow
    ];
  };
in

pkgs.writeShellScriptBin "llm-chat" ''
  set -e

  # Colors for output
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  MAGENTA='\033[0;35m'
  CYAN='\033[0;36m'
  NC='\033[0m' # No Color

  # Function to print colored output
  print_info() { echo -e "''${GREEN}[INFO]''${NC} $1"; }
  print_warn() { echo -e "''${YELLOW}[WARN]''${NC} $1"; }
  print_error() { echo -e "''${RED}[ERROR]''${NC} $1"; }
  print_prompt() { echo -e "''${CYAN}You:''${NC} "; }
  print_assistant() { echo -e "''${MAGENTA}Assistant:''${NC}"; }

  # Configuration
  HISTORY_DIR="$HOME/.local/share/llm-chat"
  TEMP_DIR="/tmp/llm-chat-$$"
  mkdir -p "$HISTORY_DIR" "$TEMP_DIR"

  # Default settings
  PROVIDER="anthropic"
  MODEL=""
  EPHEMERAL=false
  SESSION_NAME=""
  SYSTEM_PROMPT=""

  # Cleanup on exit
  cleanup() {
    rm -rf "$TEMP_DIR"
  }
  trap cleanup EXIT

  # Help message
  show_help() {
    cat << EOF
  llm-chat - Interactive LLM chat in tmux popup

  Usage:
    llm-chat [OPTIONS]

  Options:
    -p, --provider PROVIDER    LLM provider: anthropic, openai, ollama (default: anthropic)
    -m, --model MODEL          Specific model (default: provider-dependent)
    -e, --ephemeral            Don't save conversation history
    -s, --session NAME         Load/save session with given name
    -S, --system PROMPT        System prompt for the conversation
    -l, --list-sessions        List available sessions
    -h, --help                 Show this help message

  Providers and Models:
    anthropic: claude-3-7-sonnet-20250219 (default), claude-3-5-haiku-20241022
    openai:    gpt-4o (default), gpt-4o-mini, o1, o3-mini
    ollama:    llama3.2 (default), qwen2.5-coder, deepseek-r1, mistral

  Examples:
    llm-chat                                   # Quick chat with Claude
    llm-chat -p openai -m gpt-4o              # Use GPT-4o
    llm-chat -p ollama -m llama3.2            # Use local Ollama
    llm-chat -s myproject                      # Resume 'myproject' session
    llm-chat -e                                # Ephemeral chat (no history)
    llm-chat -S "You are a helpful assistant" # Custom system prompt

  Keybindings (in chat):
    Ctrl-D or 'exit' or 'quit'  Exit chat
    Ctrl-C                      Cancel current input
  EOF
  }

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      -p|--provider)
        PROVIDER="$2"
        shift 2
        ;;
      -m|--model)
        MODEL="$2"
        shift 2
        ;;
      -e|--ephemeral)
        EPHEMERAL=true
        shift
        ;;
      -s|--session)
        SESSION_NAME="$2"
        shift 2
        ;;
      -S|--system)
        SYSTEM_PROMPT="$2"
        shift 2
        ;;
      -l|--list-sessions)
        echo "Available sessions:"
        if [[ -d "$HISTORY_DIR" ]] && [[ $(ls -A "$HISTORY_DIR" 2>/dev/null) ]]; then
          ls -1 "$HISTORY_DIR" | sed 's/.json$//' | sed 's/^/  - /'
        else
          echo "  (no sessions found)"
        fi
        exit 0
        ;;
      -h|--help)
        show_help
        exit 0
        ;;
      *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
    esac
  done

  # Set default models if not specified
  if [[ -z "$MODEL" ]]; then
    case $PROVIDER in
      anthropic)
        MODEL="claude-3-7-sonnet-20250219"
        ;;
      openai)
        MODEL="gpt-4o"
        ;;
      ollama)
        MODEL="llama3.2"
        ;;
      *)
        print_error "Unknown provider: $PROVIDER"
        exit 1
        ;;
    esac
  fi

  # Get API keys from pass
  get_api_key() {
    case $PROVIDER in
      anthropic)
        ${pkgs.pass}/bin/pass tokens/console.anthropic.com/nixos-workstation-key 2>/dev/null || {
          print_error "Anthropic API key not found in pass"
          print_info "Add it with: pass insert tokens/console.anthropic.com/nixos-workstation-key"
          exit 1
        }
        ;;
      openai)
        ${pkgs.pass}/bin/pass tokens/platform.openai.com/llm-chat 2>/dev/null || \
        ${pkgs.pass}/bin/pass tokens/platform.openai.com/aider 2>/dev/null || {
          print_error "OpenAI API key not found in pass"
          print_info "Add it with: pass insert tokens/platform.openai.com/llm-chat"
          exit 1
        }
        ;;
      ollama)
        echo ""  # No API key needed for Ollama
        ;;
    esac
  }

  # Session management
  SESSION_FILE=""
  if [[ "$EPHEMERAL" == false ]]; then
    if [[ -n "$SESSION_NAME" ]]; then
      SESSION_FILE="$HISTORY_DIR/$SESSION_NAME.json"
    else
      SESSION_FILE="$HISTORY_DIR/default.json"
      SESSION_NAME="default"
    fi
  fi

  # Initialize conversation history
  CONVERSATION_FILE="$TEMP_DIR/conversation.json"
  if [[ -n "$SESSION_FILE" ]] && [[ -f "$SESSION_FILE" ]]; then
    cp "$SESSION_FILE" "$CONVERSATION_FILE"
    print_info "Resumed session: $SESSION_NAME"
  else
    echo "[]" > "$CONVERSATION_FILE"
    if [[ -n "$SESSION_NAME" ]]; then
      print_info "Started new session: $SESSION_NAME"
    else
      print_info "Started ephemeral chat"
    fi
  fi

  # Add system prompt if provided
  if [[ -n "$SYSTEM_PROMPT" ]]; then
    TEMP_CONV=$(${pkgs.jq}/bin/jq --arg role "system" --arg content "$SYSTEM_PROMPT" \
      '. += [{"role": $role, "content": $content}]' "$CONVERSATION_FILE")
    echo "$TEMP_CONV" > "$CONVERSATION_FILE"
  fi

  # Print welcome message
  echo ""
  echo -e "''${BLUE}╔════════════════════════════════════════════════════════════╗''${NC}"
  echo -e "''${BLUE}║''${NC}              ''${CYAN}LLM Chat - Interactive Assistant''${NC}              ''${BLUE}║''${NC}"
  echo -e "''${BLUE}╠════════════════════════════════════════════════════════════╣''${NC}"
  echo -e "''${BLUE}║''${NC} Provider: ''${YELLOW}$PROVIDER''${NC}                                         ''${BLUE}║''${NC}"
  echo -e "''${BLUE}║''${NC} Model:    ''${YELLOW}$MODEL''${NC}                    ''${BLUE}║''${NC}"
  echo -e "''${BLUE}║''${NC} Session:  ''${YELLOW}$([ "$EPHEMERAL" == true ] && echo "ephemeral" || echo "$SESSION_NAME")''${NC}                                      ''${BLUE}║''${NC}"
  echo -e "''${BLUE}╚════════════════════════════════════════════════════════════╝''${NC}"
  echo ""

  # Get API key
  API_KEY=$(get_api_key)

  # Function to call Anthropic API
  call_anthropic() {
    local messages="$1"
    local response_file="$2"

    ${pkgs.curl}/bin/curl -s https://api.anthropic.com/v1/messages \
      -H "content-type: application/json" \
      -H "x-api-key: $API_KEY" \
      -H "anthropic-version: 2023-06-01" \
      -d "{
        \"model\": \"$MODEL\",
        \"max_tokens\": 4096,
        \"messages\": $messages
      }" > "$response_file"
  }

  # Function to call OpenAI API
  call_openai() {
    local messages="$1"
    local response_file="$2"

    ${pkgs.curl}/bin/curl -s https://api.openai.com/v1/chat/completions \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $API_KEY" \
      -d "{
        \"model\": \"$MODEL\",
        \"messages\": $messages
      }" > "$response_file"
  }

  # Function to call Ollama API
  call_ollama() {
    local messages="$1"
    local response_file="$2"

    if ! ${pkgs.curl}/bin/curl -s http://localhost:11434/api/chat \
      -d "{
        \"model\": \"$MODEL\",
        \"messages\": $messages,
        \"stream\": false
      }" > "$response_file"; then
      print_error "Failed to connect to Ollama. Is it running?"
      print_info "Start Ollama with: ollama serve"
      return 1
    fi
  }

  # Function to extract response content
  extract_response() {
    local response_file="$1"

    case $PROVIDER in
      anthropic)
        ${pkgs.jq}/bin/jq -r '.content[0].text // .error.message // "Error: No response"' "$response_file"
        ;;
      openai)
        ${pkgs.jq}/bin/jq -r '.choices[0].message.content // .error.message // "Error: No response"' "$response_file"
        ;;
      ollama)
        ${pkgs.jq}/bin/jq -r '.message.content // .error // "Error: No response"' "$response_file"
        ;;
    esac
  }

  # Main chat loop
  while true; do
    # Get user input
    echo -ne "''${CYAN}You:''${NC} "
    read -r user_input

    # Check for exit commands
    if [[ -z "$user_input" ]] || [[ "$user_input" == "exit" ]] || [[ "$user_input" == "quit" ]]; then
      echo ""
      print_info "Goodbye!"
      break
    fi

    # Add user message to conversation
    TEMP_CONV=$(${pkgs.jq}/bin/jq --arg role "user" --arg content "$user_input" \
      '. += [{"role": $role, "content": $content}]' "$CONVERSATION_FILE")
    echo "$TEMP_CONV" > "$CONVERSATION_FILE"

    # Prepare messages for API (filter out system messages for providers that handle them differently)
    if [[ "$PROVIDER" == "anthropic" ]]; then
      # Anthropic doesn't use system messages in the messages array
      MESSAGES=$(${pkgs.jq}/bin/jq '[.[] | select(.role != "system")]' "$CONVERSATION_FILE")
    else
      MESSAGES=$(cat "$CONVERSATION_FILE")
    fi

    # Call LLM API
    RESPONSE_FILE="$TEMP_DIR/response.json"
    echo -ne "''${MAGENTA}Assistant:''${NC} "
    print_info "Thinking..."

    case $PROVIDER in
      anthropic)
        call_anthropic "$MESSAGES" "$RESPONSE_FILE"
        ;;
      openai)
        call_openai "$MESSAGES" "$RESPONSE_FILE"
        ;;
      ollama)
        call_ollama "$MESSAGES" "$RESPONSE_FILE" || continue
        ;;
    esac

    # Extract and display response
    ASSISTANT_RESPONSE=$(extract_response "$RESPONSE_FILE")

    if [[ "$ASSISTANT_RESPONSE" == "Error:"* ]] || [[ -z "$ASSISTANT_RESPONSE" ]]; then
      print_error "$ASSISTANT_RESPONSE"
      print_error "Full response: $(cat "$RESPONSE_FILE")"
      # Remove the failed user message
      TEMP_CONV=$(${pkgs.jq}/bin/jq 'del(.[-1])' "$CONVERSATION_FILE")
      echo "$TEMP_CONV" > "$CONVERSATION_FILE"
      continue
    fi

    # Display response with glow
    echo ""
    echo "$ASSISTANT_RESPONSE" | ${pkgs.glow}/bin/glow -
    echo ""

    # Add assistant response to conversation
    TEMP_CONV=$(${pkgs.jq}/bin/jq --arg role "assistant" --arg content "$ASSISTANT_RESPONSE" \
      '. += [{"role": $role, "content": $content}]' "$CONVERSATION_FILE")
    echo "$TEMP_CONV" > "$CONVERSATION_FILE"

    # Save session if not ephemeral
    if [[ -n "$SESSION_FILE" ]]; then
      cp "$CONVERSATION_FILE" "$SESSION_FILE"
    fi
  done

  # Save final session
  if [[ -n "$SESSION_FILE" ]]; then
    cp "$CONVERSATION_FILE" "$SESSION_FILE"
    print_info "Session saved: $SESSION_NAME"
  fi
''
