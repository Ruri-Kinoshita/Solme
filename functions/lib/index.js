"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.editImageOpenAI = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const openai_1 = __importDefault(require("openai"));
const uploads_1 = require("openai/uploads");
const ALLOWED_SIZES = new Set([
    "256x256",
    "512x512",
    "1024x1024",
    "1536x1024",
    "1024x1536",
    "auto",
]);
const DEFAULT_PROMPT = [
    "Bust-up pixel art portrait of a cute, fashionable character.",
    "From chest up, faithfully matching the provided reference.",
    "Chibi/anime-inspired proportions, large expressive eyes, gentle smile.",
    "Authentic retro 16-bit style with visible large pixels,",
    "clean 1-pixel outlines, flat cel shading, no gradients.",
    "Soft pastel + bright colors, 20–30 colors max.",
    "Transparent background.",
    "4:3 aspect; pixel resolution ~128x96, then upscaled without smoothing.",
    "Cozy, playful mood.",
].join(" ");
exports.editImageOpenAI = (0, https_1.onCall)({
    region: "asia-northeast1",
    secrets: ["OPENAI_API_KEY"],
    cors: true,
    invoker: "public",
}, async (request) => {
    var _a, _b, _c, _d, _e;
    try {
        const data = ((_a = request.data) !== null && _a !== void 0 ? _a : {});
        const { imageBase64, mimeType } = data;
        if (!imageBase64 || !mimeType) {
            throw new Error("imageBase64 と mimeType は必須です。");
        }
        const size = ALLOWED_SIZES.has((_b = data.size) !== null && _b !== void 0 ? _b : "") ?
            data.size :
            "1024x1024";
        const background = data.background === "transparent" ||
            data.background === "auto" ||
            data.background === "opaque" ?
            data.background :
            "transparent";
        const prompt = (_c = data.prompt) !== null && _c !== void 0 ? _c : DEFAULT_PROMPT;
        const client = new openai_1.default({ apiKey: process.env.OPENAI_API_KEY });
        // Base64 -> Uploadable
        const buf = Buffer.from(imageBase64, "base64");
        const filename = mimeType.includes("png") ? "input.png" : "input.jpg";
        const uploadable = await (0, uploads_1.toFile)(buf, filename, { type: mimeType });
        const result = await client.images.edit({
            model: "gpt-image-1",
            image: uploadable,
            prompt,
            size,
            background,
            response_format: "b64_json",
        });
        const b64 = (_e = (_d = result.data) === null || _d === void 0 ? void 0 : _d[0]) === null || _e === void 0 ? void 0 : _e.b64_json;
        if (!b64) {
            throw new Error("画像が返りませんでした。");
        }
        return {
            imageBase64: b64,
            mimeType: "image/png",
        };
    }
    catch (err) {
        logger.error(err);
        const msg = err instanceof Error ? err.message : "画像編集に失敗しました";
        throw new Error(msg);
    }
});
//# sourceMappingURL=index.js.map