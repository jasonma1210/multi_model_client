#!/usr/bin/env python3
"""
ModelScope 模型下载脚本
使用官方 modelscope SDK 下载模型到本地

用法:
    python modelscope_download.py <model_id> [--cache_dir <目录>] [--output_dir <目录>]
"""

import argparse
import json
import os
import sys
import time
from pathlib import Path

try:
    from modelscope import snapshot_download, HubApi
except ImportError:
    print(json.dumps({
        "success": False,
        "error": "modelscope SDK 未安装，请运行: pip install modelscope"
    }))
    sys.exit(1)


def download_model(model_id: str, cache_dir: str = None, output_dir: str = None, revision: str = "master"):
    """
    下载 ModelScope 模型

    Args:
        model_id: 模型ID，格式如 'ZhipuAI/chatglm3-6b'
        cache_dir: 缓存目录（可选）
        output_dir: 输出目录（可选）
        revision: 版本分支，默认为 master

    Returns:
        dict: 下载结果
    """
    try:
        # 设置下载参数
        kwargs = {
            'model_id': model_id,
            'revision': revision,
        }

        if cache_dir:
            kwargs['cache_dir'] = cache_dir

        if output_dir:
            kwargs['output_dir'] = output_dir

        print(f"开始下载模型: {model_id}", flush=True)

        # 执行下载
        start_time = time.time()
        model_dir = snapshot_download(**kwargs)
        download_time = time.time() - start_time

        # 获取模型文件信息
        model_files = []
        if os.path.exists(model_dir):
            for root, dirs, files in os.walk(model_dir):
                for file in files:
                    file_path = os.path.join(root, file)
                    file_size = os.path.getsize(file_path)
                    relative_path = os.path.relpath(file_path, model_dir)
                    model_files.append({
                        "name": relative_path,
                        "size": file_size,
                        "path": file_path
                    })

        result = {
            "success": True,
            "model_id": model_id,
            "model_dir": model_dir,
            "files": model_files,
            "download_time": round(download_time, 2),
            "total_size": sum(f["size"] for f in model_files)
        }

        print(json.dumps(result), flush=True)
        return result

    except Exception as e:
        error_result = {
            "success": False,
            "model_id": model_id,
            "error": str(e),
            "error_type": type(e).__name__
        }
        print(json.dumps(error_result), flush=True)
        return error_result


def list_model_files(model_id: str, revision: str = "master"):
    """
    列出模型文件

    Args:
        model_id: 模型ID
        revision: 版本分支

    Returns:
        dict: 文件列表
    """
    try:
        api = HubApi()
        model_info = api.get_model(model_id)
        files = model_info.get('snapshots', [])

        result = {
            "success": True,
            "model_id": model_id,
            "files": files
        }

        print(json.dumps(result), flush=True)
        return result

    except Exception as e:
        error_result = {
            "success": False,
            "model_id": model_id,
            "error": str(e)
        }
        print(json.dumps(error_result), flush=True)
        return error_result


def get_model_info(model_id: str):
    """
    获取模型信息

    Args:
        model_id: 模型ID

    Returns:
        dict: 模型信息
    """
    try:
        api = HubApi()
        model_info = api.get_model(model_id)

        result = {
            "success": True,
            "model_id": model_id,
            "name": model_info.get('Name', ''),
            "author": model_info.get('Owner', ''),
            "description": model_info.get('Description', ''),
            "downloads": model_info.get('Downloads', 0),
            "likes": model_info.get('Likes', 0),
            "tags": model_info.get('Tags', []),
            "license": model_info.get('License', ''),
            "size": model_info.get('Size', 0),
            "file_count": model_info.get('FileCount', 0),
        }

        print(json.dumps(result), flush=True)
        return result

    except Exception as e:
        error_result = {
            "success": False,
            "model_id": model_id,
            "error": str(e)
        }
        print(json.dumps(error_result), flush=True)
        return error_result


def main():
    parser = argparse.ArgumentParser(description='ModelScope 模型下载工具')
    parser.add_argument('command', choices=['download', 'list', 'info'],
                        help='要执行的命令')
    parser.add_argument('model_id', help='模型ID')
    parser.add_argument('--cache_dir', help='缓存目录', default=None)
    parser.add_argument('--output_dir', help='输出目录', default=None)
    parser.add_argument('--revision', help='版本分支', default='master')

    args = parser.parse_args()

    if args.command == 'download':
        download_model(
            model_id=args.model_id,
            cache_dir=args.cache_dir,
            output_dir=args.output_dir,
            revision=args.revision
        )
    elif args.command == 'list':
        list_model_files(
            model_id=args.model_id,
            revision=args.revision
        )
    elif args.command == 'info':
        get_model_info(model_id=args.model_id)


if __name__ == '__main__':
    main()